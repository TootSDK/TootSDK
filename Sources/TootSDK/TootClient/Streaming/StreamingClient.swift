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
    
    internal class Subscriber: Hashable, Identifiable {
        static func == (lhs: StreamingClient.Subscriber, rhs: StreamingClient.Subscriber) -> Bool {
            return lhs.timeline == rhs.timeline && lhs.id == rhs.id
        }
        
        let timeline: StreamingTimeline
        var continuation: Stream.Continuation
        
        fileprivate init(timeline: StreamingTimeline, continuation: Stream.Continuation) {
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
    
    /// The maximum number of connection attempts to make, including successful ones.
    ///
    /// This limit attempts to prevent excessive handshakes if the connection is available but unreliable.
    public var maxConnectionAttempts = 10
    
    private var subscribers: Set<Subscriber> = []
    private var connection: TootSocket? = nil
    private var connectionTask: Task<Void, Error>? = nil
    /// The number of unsuccessful connection attempts that have been made.
    private var unsuccessfulConnectionAttempts = 0
    /// The total number of connection attmepts that have been made, including successful ones.
    private var totalConnectionAttempts = 0
    weak private var client: TootClient?
    
    internal init(client: TootClient, maxRetries: Int = 5) {
        self.client = client
        self.maxRetries = maxRetries
    }
    
    /// Subscribe to a stream of events from a ``StreamingTimeline``.
    ///
    /// Begins a WebSocket connection if there is not already one; otherwise, subscribes to the timeline using the existing connection.
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
        
        // If there is an existing connection and we are not already subscribed, send subscribe request. Otherwise, attempt to start a connection if necessary.
        if let connection {
            if !isAlreadySubscribed {
                try await connection.sendQuery(.init(.subscribe, timeline: timeline))
            }
        } else if connectionTask?.isCancelled ?? true {
            // if there is not an existing connection task or the existing task is cancelled, start a new connection
            guard let client else {
                throw TootSDKError.clientDeinited
            }
            startConnection(client: client)
        }
        
        return stream
    }
    
    /// Remove a subscriber. If there are no remaining subscribers to its ``StreamingTimeline`` and there is an active connection, unsubscribe from that timeline.
    fileprivate func unsubscribe(_ subscriber: Subscriber) async throws {
        subscribers.remove(subscriber)
        
        // If the last subscriber is unsubscribing from this timeline and there is an active connection, send unsubscribe to server
        if !subscribers.contains(where: { $0.timeline == subscriber.timeline }) {
            try await connection?.sendQuery(.init(.unsubscribe, timeline: subscriber.timeline))
        }
    }
    
    /// For a given ``StreamingEvent``, distribute its ``EventContent`` to all subscribers who subscribe to that timeline.
    private func distributeToSubscribers(_ event: StreamingEvent) {
        let relevantSubscribers = subscribers.filter({ $0.timeline == event.timeline })
        for subscriber in relevantSubscribers {
            subscriber.continuation.yield(event.event)
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
    ///
    /// When the connection is successfully opened, will send subscribe requests for any existing subscribers.
    private func startConnection(client: TootClient) {
        guard connectionTask?.isCancelled ?? true else {
            return
        }
        
        self.connectionTask = Task.detached { [weak self] in
            try await self?.maintainConnection(client: client)
        }
    }
    
    /// Start a connection, notify the server of all our subscriptions, and send the resulting events to each subscriber who subscribed to that timeline.
    ///
    /// Sets `connection` to the active ``TootSocket`` instance for the duration of the connection, then sets `connection` to nil when the connection ends.
    private func connectAndReceiveEvents(client: TootClient) async throws {
        let socket = try await client.beginStreaming()
        self.connection = socket
        
        // Close connection when finished.
        defer {
            socket.close(with: .normalClosure)
            self.connection = nil
        }
        
        // Send subscription request for the timelines of existing subscribers
        let subscribedTimelines = Set(subscribers.map({ $0.timeline }))
        for subscription in subscribedTimelines {
            try await socket.sendQuery(.init(.subscribe, timeline: subscription))
        }
        
        // If we haven't sent any subscription requests, send a ping to the server to verify that the connection is alive.
        if subscribedTimelines.isEmpty {
            try await socket.sendPing()
        }
        
        unsuccessfulConnectionAttempts = 0
        
        for try await event in socket.stream {
            distributeToSubscribers(event)
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
        
        unsuccessfulConnectionAttempts = 0
        totalConnectionAttempts = 0
        repeat {
            // exponential backoff after multiple failed connection attempts
            if unsuccessfulConnectionAttempts > 0 {
                try await Task.sleep(nanoseconds: 2_000_000_000 ^ UInt64(unsuccessfulConnectionAttempts))
            }
            
            unsuccessfulConnectionAttempts += 1
            totalConnectionAttempts += 1
            
            do {
                try await connectAndReceiveEvents(client: client)
            } catch is CancellationError {
                // if the task is cancelled, end the loop without trying again
                return
            } catch {
                // if there is any other error, continue to the next iteration of the retry loop
                continue
            }
        } while unsuccessfulConnectionAttempts < maxRetries &&
            totalConnectionAttempts < maxConnectionAttempts &&
            !Task.isCancelled
    }
    
    deinit {
        self.connectionTask?.cancel()
    }
}
