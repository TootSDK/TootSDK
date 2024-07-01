//
//  TootClient+Streaming.swift
//
//
//  Created by Dale Price on 5/23/24.
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Encapsulates a WebSocket connection to a server for streaming timeline updates.
public class TootSocket {
    /// The underlying WebSocket task.
    private let webSocketTask: URLSessionWebSocketTask
    private let encoder = TootEncoder()
    private let decoder = TootDecoder()
    public private(set) var isClosed = false

    /// Async throwing stream of all ``StreamingEvent``s sent by the server.
    ///
    /// > Throws:
    /// > - ``TootSDKError/decodingError(_:)`` if a received message cannot be decoded as a ``StreamingEvent``.
    /// > - An `NSError` if the web socket task encounters an error receiving a message.
    /// > - `CancellationError` if the containing task has been cancelled while waiting for a message.
    public lazy var stream: AsyncThrowingStream<StreamingEvent, Error> = {
        AsyncThrowingStream<StreamingEvent, Error> { [webSocketTask, decoder] in
            do {
                let message = try await webSocketTask.receive()
                let data =
                    switch message {
                    case .data(let data):
                        data
                    case .string(let string):
                        string.data(using: .utf8)
                    @unknown default:
                        throw TootSDKError.decodingError("message")
                    }
                guard let data else { throw TootSDKError.decodingError("message data") }

                return try decoder.decode(StreamingEvent.self, from: data)
            } catch {
                // URLSessionWebSocketTask.receive() doesn't respond to Task cancellation, so we need to check if the task has already been cancelled at the time that it throws any error.
                try Task.checkCancellation()
                // Only throw the underlying error if the task has not been cancelled.
                throw error
            }
        }
    }()

    /// Send a JSON-encoded request to subscribe to or unsubscribe from a streaming timeline.
    ///
    /// - Parameter query: The request to subscribe or unsubscribe to a particular streaming timeline.
    /// - Throws: Any thrown errors from `TootEncoder/encode()` or `URLSessionWebSocketTask/send()`.
    ///
    /// - SeeAlso: [Mastodon API: WebSocket query parameters](https://docs.joinmastodon.org/methods/streaming/#parameters)
    public func sendQuery(_ query: StreamQuery) async throws {
        let encodedQuery = try encoder.encode(query)
        // In theory we can just send the encoded Data over the websocket. In practice, Mastodon has an undocumented requirement to only send strings or it will immediately terminate the connection. So we have to recast the data we just encoded to a string.
        guard let encodedString = String(data: encodedQuery, encoding: .utf8) else {
            throw TootSDKError.internalError("Unable to read UTF-8 string from encoded JSON.")
        }
        try await webSocketTask.send(.string(encodedString))
    }

    /// Send a ping to the streaming server asynchronously. Returns when a pong is received back from the server.
    ///
    /// If called multiple times, returns in the order that it was called.
    ///
    /// - Throws: `NSError` if the connection is lost or any other problem occurs.
    public func sendPing() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            webSocketTask.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// Close the connection.
    /// - Parameters:
    ///   - closeCode: The reason for closing the connection.
    public func close(with closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        guard !isClosed else {
            return
        }
        if webSocketTask.closeCode == .invalid {
            webSocketTask.cancel(with: closeCode, reason: nil)
        }
        isClosed = true
    }

    internal init(webSocketTask: URLSessionWebSocketTask) {
        self.webSocketTask = webSocketTask
        self.webSocketTask.resume()
    }

    deinit {
        close(with: .normalClosure)
    }
}

extension TootClient {
    /// Opens a WebSocket connection to the server's streaming API, after checking that it is available and alive.
    ///
    /// This is a lower-level option that provides the ability to handle events and send subscribe/unsubscribe requests to the socket directly. For a higher-level API, see ``TootClient/streaming`` instead.
    ///
    /// - Important: If you use this method directly, you are responsible for following best practices to minimize unnecessary load on the server.
    ///
    /// To minimize server load, it is recommended to:
    /// - Only open one streaming connection at a time per account.
    /// - Reuse a single, long-lived streaming connection instead of opening a new one for each ``StreamingTimeline`` you subscribe to; send ``StreamQuery`` to subscribe/unsubscribe to only the timelines you need.
    /// - Add an increasing delay between retries if the connection fails.
    /// - Limit the total number of retries to avoid retrying indefinitely in the event that the connection is unreliable.
    ///
    /// - Returns: If the server provides a streaming API via ``TootClient/getInstanceInfo()`` and it is alive according to ``TootClient/getStreamingHealth()``, returns a ``TootSocket`` instance representing the connection.
    ///
    /// > Throws:
    /// > - ``TootSDKError/streamingUnsupported`` if the server does not provide a valid URL for the streaming endpoint.
    /// > - ``TootSDKError/streamingEndpointUnhealthy`` if the server does not affirm that the streaming API is alive.
    /// > - ``TootSDKError/unsupportedFlavour(current:required:)`` if TootSDK doesn't support streaming to the instance flavour.
    /// > - `CancellationError` if the task is cancelled prior to creating the socket.
    public func beginStreaming() async throws -> TootSocket {
        try requireFeature(.streaming)

        // get streaming endpoint URL from instance info
        async let streamingEndpoint = getInstanceInfo().urls?.streamingApi
        async let streamingHealthy = getStreamingHealth()

        guard let streamingEndpoint = try await streamingEndpoint,
            let streamingURL = URL(string: streamingEndpoint)
        else {
            throw TootSDKError.streamingUnsupported
        }
        guard try await streamingHealthy else {
            throw TootSDKError.streamingEndpointUnhealthy
        }

        let req = HTTPRequestBuilder {
            $0.url = getURL(base: streamingURL, appendingComponents: ["api", "v1", "streaming"])
        }

        try Task.checkCancellation()
        let task = try webSocketTask(req)

        return TootSocket(webSocketTask: task)
    }

    /// Check whether the streaming endpoint is alive.
    ///
    /// - Returns: `true` if the server returns HTTP status code `200`, indicating that the streaming endpoint is alive.
    public func getStreamingHealth() async throws -> Bool {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "streaming", "health"])
            $0.method = .get
        }
        let (_, response) = try await fetch(req: req)
        return response.statusCode == 200
    }

    /// Creates a web socket task with the given query items, and the access token if the client is authenticated.
    ///
    /// Analogous to `TootClient.fetch(req:)`, but for a WebSocket connection.
    ///
    /// - Parameters:
    ///   - req: an `HTTPRequestBuilder` configured with a URL that can accept WebSocket connections.
    ///
    /// - Returns: The result of calling the client's `session.webSocketTask(with:protocols:)` with the given query items and the access token if available.
    ///
    /// - Throws: ``TootSDKError/requiredURLNotSet`` if the request does not have a URL set.
    internal func webSocketTask(_ req: HTTPRequestBuilder) throws -> URLSessionWebSocketTask {
        if req.headers.index(forKey: "User-Agent") == nil {
            req.headers["User-Agent"] = "TootSDK"
        }

        if let accessToken {
            // This is undocumented, but the Mastodon streaming API allows passing the access token using the protocol header.
            // This is slightly more secure than the documented method of putting the access token in plain text in the query string.
            req.headers["Sec-WebSocket-Protocol"] = accessToken
        }

        return session.webSocketTask(with: try req.build())
    }
}

extension TootFeature {

    /// Ability to stream incoming events via WebSocket
    ///
    public static let streaming = TootFeature(supportedFlavours: [.mastodon, .pleroma, .akkoma])
}
