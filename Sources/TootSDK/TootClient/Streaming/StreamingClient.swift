//
//  StreamingClient.swift
//
//
//  Created by Dale Price on 5/24/24.
//

import Foundation

/// Automatically attempts to maintain a WebSocket connection to the server, allows any number of consumers to subscribe to any number of ``StreamingTimeline`` over the socket.
///
/// To get server-sent events for a timeline, call ``subscribe(to:)`` to get an AsyncStream of ``EventContent`` corresponding to that timeline. When finished, simply cancel the task. The client will automatically send the server an unsubscribe request when all tasks requesting a particular timeline have been cancelled.
///
/// All streams will finish when ``StreamingClient/maxRetries`` unsuccessful connection attempts have been made or you call ``StreamingClient/disconnect()``.
public actor StreamingClient {
    public typealias Stream = AsyncStream<EventContent>
    
    internal class Subscriber: Hashable {
        static func == (lhs: StreamingClient.Subscriber, rhs: StreamingClient.Subscriber) -> Bool {
            return lhs.timeline == rhs.timeline && lhs.id == rhs.id
        }
        
        let timeline: StreamingTimeline
        let id: UUID
        var continuation: Stream.Continuation
        
        fileprivate init(timeline: StreamingTimeline, continuation: Stream.Continuation) {
            self.id = .init()
            self.timeline = timeline
            self.continuation = continuation
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(timeline)
            hasher.combine(id)
        }
    }
    
    /// The maximum number of retries if the connection attempt is unsuccessful.
    public var maxRetries = 5
    
    private var subscribers: Set<Subscriber> = []
    private var connection: TootSocket? = nil
    private var connectionTask: Task<Void, Error>? = nil
    /// The number of unsuccessful connection attempts that have been made.
    private var connectionAttempts = 0
    weak private var client: TootClient?
    
    internal init(client: TootClient, maxRetries: Int = 5) {
        self.client = client
        self.maxRetries = maxRetries
    }
    
    public func subscribe(to timeline: StreamingTimeline) async throws -> Stream {
        // Check if we are already subscribed to this timeline
        let isAlreadySubscribed: Bool
        if connection != nil {
            isAlreadySubscribed = subscribers.contains(where: { $0.timeline == timeline })
        } else {
            isAlreadySubscribed = false
        }
        
        // Create an AsyncStream that we can store the continuation and yield values to as we receive them.
        let stream = Stream { continuation in
            let subscriber = Subscriber(timeline: timeline, continuation: continuation)
            self.subscribers.insert(subscriber)
            continuation.onTermination = { _ in
                // When the stream is terminated, remove this subscriber.
                Task {
                    try? await self.unsubscribe(subscriber)
                }
            }
        }
        
        // If there is an existing connection and we are not already subscribed, send subscribe request. Otherwise, attempt to start a connection.
        if let connection {
            if !isAlreadySubscribed {
                try await connection.sendQuery(.init(.subscribe, timeline: timeline))
            }
        } else if connectionTask?.isCancelled ?? true, let client {
            startConnection(client: client)
        }
        
        return stream
    }
    
    fileprivate func unsubscribe(_ subscriber: Subscriber) async throws {
        subscribers.remove(subscriber)
        
        // If the last subscriber is unsubscribing from this timeline and there is an active connection, send unsubscribe to server
        if !subscribers.contains(where: { $0.timeline == subscriber.timeline }) {
            try await connection?.sendQuery(.init(.unsubscribe, timeline: subscriber.timeline))
        }
    }
    
    /// End the active connection if there is one, and end all subscribed streams.
    public func disconnect() {
        if let connectionTask {
            connectionTask.cancel()
            self.connectionTask = nil
        }
    }
    
    /// Unless there is already an active connection task, start a new one.
    private func startConnection(client: TootClient) {
        guard connectionTask?.isCancelled ?? true else {
            return
        }
        
        self.connectionTask = Task.detached { [weak self] in
            try await self?.maintainConnection(client: client)
        }
    }
    
    /// Start a connection, notify the server of all our subscriptions, and send the resulting events to each subscriber who subscribed to that timeline.
    private func connect(client: TootClient) async throws {
        let subscriptions = subscribers.map({ $0.timeline })
        
        let socket = try await client.beginStreaming()
        self.connection = socket
        
        // Close connection when finished.
        defer {
            socket.webSocketTask.cancel(with: .normalClosure, reason: nil)
            self.connection = nil
        }
        
        // Send subscription request for all existing subscribers
        for subscription in subscriptions {
            try await socket.sendQuery(.init(.subscribe, timeline: subscription))
        }
        
        connectionAttempts = 0
        
        for try await event in socket.stream {
            let relevantSubscribers = subscribers.filter({ $0.timeline == event.timeline })
            for subscriber in relevantSubscribers {
                subscriber.continuation.yield(event.event)
            }
        }
    }
    
    /// Attempt to maintain a connection over time, retrying up to the limit specified by `maxRetries` if the connection is unsuccessful, and backing off exponentially between subsequent retires.
    private func maintainConnection(client: TootClient) async throws {
        // When finished for any reason, end the stream for all subscribers
        defer {
            for subscriber in subscribers {
                subscriber.continuation.finish()
            }
        }
        
        connectionAttempts = 0
        repeat {
            if connectionAttempts > 0 {
                try await Task.sleep(nanoseconds: 2_000_000_000 ^ UInt64(connectionAttempts))
            }
            connectionAttempts += 1
            try await connect(client: client)
        } while connectionAttempts < maxRetries && !Task.isCancelled
    }
    
    deinit {
        self.connectionTask?.cancel()
    }
}
