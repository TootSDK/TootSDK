//
//  StreamingClient.swift
//
//
//  Created by Dale Price on 5/24/24.
//

import Foundation

#if canImport(OSLog)
    import OSLog
#endif

/// Automatically attempts to maintain a WebSocket connection to the server, allows any number of consumers to subscribe to any number of ``StreamingTimeline`` over the socket. Handles connection issues in a way that is as transparent to subscribers as possible.
///
/// To get server-sent events for a timeline, call ``subscribe(to:)`` to get an AsyncThrowingStream of ``StreamingClient/Event`` corresponding to that timeline. When finished, simply cancel the task. The client will automatically send the server an unsubscribe request when all tasks requesting a particular timeline have been cancelled.
///
/// The WebSocket connection will remain open even after all subscriptions have ended, allowing the same connection to be reused for future subscriptions. If you do not want the connection to remain open, you must either call ``disconnect()`` or dispose of the ``StreamingClient`` instance.
///
/// Automatically retries with exponential backoff after failed connections, and limits retries to a configurable maximum amount (``maxRetries`` for subsequent unsuccessful attempts; ``maxConnectionAttempts`` for all attempts).
///
/// All streams will finish when ``StreamingClient/maxRetries`` unsuccessful connection attempts have been made or you call ``StreamingClient/disconnect()``.
public actor StreamingClient {

    /// A change in the status of the streaming connection, or an event received from the server.
    public enum Event: Sendable {
        /// Streaming connection has been established successfully.
        case connectionUp

        /// Streaming connection is down.
        ///
        /// To avoid missing posts, switch to using the HTTP API when you receive this event.
        ///
        /// This condition may be temporary or indefinite depending on ``StreamingClient/maxRetries`` and ``StreamingClient/maxConnectionAttempts``.
        case connectionDown

        /// Received an event from the server on the timeline that you're subscribed to.
        case receivedEvent(EventContent)
    }

    public typealias Stream = AsyncThrowingStream<Event, Error>

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

    /// Is the connection currently active?
    ///
    /// The state of this property matches ``Event/connectionUp`` and ``Event/connectionDown`` events being sent to subscribers.
    public private(set) var isConnectionUp: Bool = false

    private var subscribers: Set<Subscriber> = []
    private var connection: TootSocket? = nil
    private var connectionTask: Task<Void, Error>? = nil
    /// The number of unsuccessful connection attempts that have been made.
    private var unsuccessfulConnectionAttempts = 0
    /// The total number of connection attmepts that have been made, including successful ones.
    private var totalConnectionAttempts = 0
    weak private var client: TootClient?

    #if canImport(OSLog)
        static private let logger = Logger(subsystem: "TootSDK", category: "StreamingClient")
    #endif

    internal init(client: TootClient) {
        self.client = client
    }

    /// Subscribe to a stream of events from a ``StreamingTimeline``.
    ///
    /// Begins a WebSocket connection if there is not already one; otherwise, subscribes to the timeline using the existing connection. If the connection is currently down between retry attempts, will wait until the next successful connection to send the subscribe request, unless ``disconnect()`` is called before then.
    ///
    /// - Parameters:
    ///   - timeline: A ``StreamingTimeline`` to receive events for.
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream’s buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    ///
    /// - Returns: An `AsyncThrowingStream` of ``Event`` values for connection status changes and events received from the server. This stream throws an error if the connection irrecoverably ends.
    ///
    /// - Throws: ``TootSDKError/clientDeinited`` if there is no ``TootClient`` instance available to start a connection on.
    public func subscribe(to timeline: StreamingTimeline, bufferingPolicy: Stream.Continuation.BufferingPolicy = .unbounded) async throws -> Stream {
        // Check if we are already subscribed to this timeline
        let isAlreadySubscribed: Bool
        if connection != nil {
            isAlreadySubscribed = subscribers.contains(where: { $0.timeline == timeline })
        } else {
            isAlreadySubscribed = false
        }

        // Create an AsyncStream that we can store the continuation and yield values to as we receive them.
        let stream = Stream(bufferingPolicy: bufferingPolicy) { continuation in
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
                #if canImport(OSLog)
                    Self.logger.debug("Sending subscribe query for new subscriber to timeline \(timeline.rawValue).")
                #endif
                try? await connection.sendQuery(.init(.subscribe, timeline: timeline))
                // We can ignore any error here because the next connection attempt in `maintainConnection()` will resend the subscribe request if this one fails.
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

        try Task.checkCancellation()
        // If the last subscriber is unsubscribing from this timeline and there is an active connection, send unsubscribe to server
        if !subscribers.contains(where: { $0.timeline == subscriber.timeline }) {
            #if canImport(OSLog)
                Self.logger.debug("Sending unsubscribe query for timeline \(subscriber.timeline.rawValue) because last subscriber unsubscribed.")
            #endif
            try await connection?.sendQuery(.init(.unsubscribe, timeline: subscriber.timeline))
        }
    }

    /// For a given ``StreamingEvent``, distribute its ``EventContent`` to all subscribers who subscribe to that timeline.
    private func distributeToSubscribers(_ event: StreamingEvent) {
        let relevantSubscribers = subscribers.filter({ $0.timeline == event.timeline })
        for subscriber in relevantSubscribers {
            subscriber.continuation.yield(.receivedEvent(event.event))
        }
    }

    /// Cause all subscribers' streams to end by throwing the given error.
    private func throwToSubscribers(_ error: Error) {
        for subscriber in subscribers {
            subscriber.continuation.finish(throwing: error)
        }
    }

    /// End the active connection if there is one, and end all subscribed streams.
    public func disconnect() {
        if let connectionTask {
            #if canImport(OSLog)
                Self.logger.info("`disconnect()` called, cancelling current streaming connection task.")
            #endif
            connectionTask.cancel()
            self.connection = nil
            self.isConnectionUp = false
            // notify subscribers that the connection has closed
            for subscriber in subscribers {
                subscriber.continuation.yield(.connectionDown)
            }
            self.connectionTask = nil
        }
    }

    /// Unless there is already an active connection task, start a new one.
    ///
    /// When the connection is successfully opened, will send subscribe requests for any existing subscribers.
    private func startConnection(client: TootClient) {
        guard connectionTask?.isCancelled ?? true else {
            #if canImport(OSLog)
                Self.logger.warning(
                    "`startConnection(client:)` called but there is already an active connection task. Leaving existing connection task in place.")
            #endif
            return
        }

        #if canImport(OSLog)
            Self.logger.notice("Starting new streaming connection task.")
        #endif
        self.connectionTask = Task.detached { [weak self] in
            try await self?.maintainConnection(client: client)
        }
    }

    /// Start a connection, notify the server of all our subscriptions, and send the resulting events to each subscriber who subscribed to that timeline.
    ///
    /// Sets `connection` to the active ``TootSocket`` instance for the duration of the connection, then sets `connection` to nil when the connection ends.
    private func connectAndReceiveEvents(client: TootClient) async throws {
        #if canImport(OSLog)
            Self.logger.info("Opening streaming connection.")
        #endif
        let socket = try await client.beginStreaming()
        self.connection = socket

        // Close socket when finished.
        defer {
            #if canImport(OSLog)
                Self.logger.info("Streaming connection ended.")
            #endif
            socket.close(with: .normalClosure)
            if self.connection === socket {
                self.connection = nil
                self.isConnectionUp = false
                // notify subscribers that the connection has closed
                for subscriber in subscribers {
                    subscriber.continuation.yield(.connectionDown)
                }
            }
        }

        try await withTaskCancellationHandler {
            // Send subscription request for the timelines of existing subscribers
            let subscribedTimelines = Set(subscribers.map({ $0.timeline }))
            #if canImport(OSLog)
                Self.logger.debug("Sending subscribe queries for \(subscribedTimelines.count) timelines on behalf of existing subscribers.")
            #endif
            for subscription in subscribedTimelines {
                try Task.checkCancellation()
                try await socket.sendQuery(.init(.subscribe, timeline: subscription))
            }

            // If we haven't sent any subscription requests, send a ping to the server to verify that the connection is alive.
            if subscribedTimelines.isEmpty {
                try Task.checkCancellation()
                try await socket.sendPing()
            }

            #if canImport(OSLog)
                Self.logger.info("Streaming connection opened successfully.")
            #endif

            unsuccessfulConnectionAttempts = 0

            // Notify subscribers that the connection is up and we are listening for events
            self.isConnectionUp = true
            for subscriber in subscribers {
                subscriber.continuation.yield(.connectionUp)
            }

            for try await event in socket.stream {
                #if canImport(OSLog)
                    Self.logger.debug("Received streaming event for timeline \(event.timeline.rawValue).")
                #endif
                distributeToSubscribers(event)
            }
        } onCancel: {
            socket.close(with: .normalClosure)
        }
    }

    /// Attempt to maintain a connection over time, retrying up to the limit specified by `maxRetries` if the connection is unsuccessful, and backing off exponentially between subsequent retires.
    private func maintainConnection(client: TootClient) async throws {
        // When finished for any reason, end the stream for all subscribers, and discard all subscribers since their stream continuations are no longer usable.
        defer {
            for subscriber in subscribers {
                subscriber.continuation.finish()
            }
            subscribers.removeAll()
        }

        unsuccessfulConnectionAttempts = 0
        totalConnectionAttempts = 0
        repeat {
            // exponential backoff after multiple failed connection attempts
            if unsuccessfulConnectionAttempts > 0 {
                let waitSeconds = 2 ^ unsuccessfulConnectionAttempts
                #if canImport(OSLog)
                    Self.logger.notice("Waiting \(waitSeconds) seconds to retry streaming connection.")
                #endif
                try await Task.sleep(nanoseconds: 1_000_000_000 * UInt64(waitSeconds))
            }

            #if canImport(OSLog)
                Self.logger.notice(
                    "Attempting streaming connection. Failed attempts: \(self.unsuccessfulConnectionAttempts, align: .right(columns: 2))/\(self.maxRetries), Total attempts: \(self.totalConnectionAttempts, align: .right(columns: 2))/\(self.maxConnectionAttempts)"
                )
            #endif

            unsuccessfulConnectionAttempts += 1
            totalConnectionAttempts += 1

            do {
                try await connectAndReceiveEvents(client: client)
            } catch is CancellationError {
                // if the task is cancelled, end the loop without trying again
                #if canImport(OSLog)
                    Self.logger.notice("Streaming connection cancelled.")
                #endif
                return
            } catch TootSDKError.unsupportedFlavour(let current, let required) {
                // If the instance flavour is unsupported, don't retry.
                #if canImport(OSLog)
                    Self.logger.notice("Instance flavour '\(current.rawValue)' does not support streaming.")
                #endif
                throwToSubscribers(TootSDKError.unsupportedFlavour(current: current, required: required))
                return
            } catch TootSDKError.streamingUnsupported {
                // If the instance doesn't provide a streaming URL, don't retry.
                #if canImport(OSLog)
                    Self.logger.notice("Instance does not provide a valid URL for its streaming API.")
                #endif
                throwToSubscribers(TootSDKError.streamingUnsupported)
                return
            } catch {
                // if there is any other error, continue to the next iteration of the retry loop, or throw it to all subscriber streams if there are no more retries left
                #if canImport(OSLog)
                    Self.logger.notice("Streaming connection threw error: \(error.localizedDescription)")
                #endif
                if unsuccessfulConnectionAttempts >= maxRetries {
                    #if canImport(OSLog)
                        Self.logger.notice("Reached streaming retry limit (\(self.maxRetries)), will not automatically attempt to reconnect.")
                    #endif
                    throwToSubscribers(TootSDKError.streamingClientReachedMaxRetries(lastFailureReason: error.localizedDescription))
                } else if totalConnectionAttempts >= maxConnectionAttempts {
                    #if canImport(OSLog)
                        Self.logger.notice(
                            "Reached limit for streaming connection attempts (\(self.maxConnectionAttempts)), will not automatically attempt to reconnect."
                        )
                    #endif
                    throwToSubscribers(TootSDKError.streamingClientReachedMaxConnectionAttempts(lastFailureReason: error.localizedDescription))
                }
                continue
            }
        } while unsuccessfulConnectionAttempts < maxRetries && totalConnectionAttempts < maxConnectionAttempts && !Task.isCancelled
    }

    deinit {
        self.connectionTask?.cancel()
    }
}
