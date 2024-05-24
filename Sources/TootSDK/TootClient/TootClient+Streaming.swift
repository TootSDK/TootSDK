//
//  TootClient+Streaming.swift
//
//
//  Created by Dale Price on 5/23/24.
//

import Foundation

public class TootSocket {
    public let webSocketTask: URLSessionWebSocketTask
    private let encoder = TootEncoder()
    private let decoder = TootDecoder()
    
    public lazy var stream: AsyncThrowingStream<StreamingEvent, Error> = {
        AsyncThrowingStream<StreamingEvent, Error> { [weak webSocketTask, weak decoder] in
            guard let webSocketTask else { return nil }
            
            let message = try await webSocketTask.receive()
            let data = switch message {
            case .data(let data):
                data
            case .string(let string):
                string.data(using: .utf8)
            @unknown default:
                throw TootSDKError.decodingError("message")
            }
            guard let data else { throw TootSDKError.decodingError("message data") }
            
            guard let decoder else { return nil }
            return try decoder.decode(StreamingEvent.self, from: data)
        }
    }()
    
    public func sendQuery(_ query: StreamQuery) async throws {
        let encodedQuery = try encoder.encode(query)
        try await webSocketTask.send(.data(encodedQuery))
    }
    
    internal init(webSocketTask: URLSessionWebSocketTask) {
        self.webSocketTask = webSocketTask
        self.webSocketTask.resume()
    }
    
    deinit {
        webSocketTask.cancel(with: .normalClosure, reason: nil)
    }
}

extension TootClient {
    public func beginStreaming(_ query: StreamQuery) async throws -> TootSocket {
        // TODO: make sure instance flavor supports streaming
        
        // get streaming endpoint URL from instance info
        async let streamingEndpoint = getInstanceInfo().urls?.streamingApi
        async let streamingHealthy = getStreamingHealth()
        
        guard let streamingEndpoint = try await streamingEndpoint,
              let streamingURL = URL(string: streamingEndpoint) else {
            throw TootSDKError.streamingUnsupported
        }
        guard try await streamingHealthy else {
            throw TootSDKError.streamingEndpointUnhealthy
        }
        
        var queryItems: [URLQueryItem] = [.init(name: "stream", value: query.stream)]
        if let list = query.list { queryItems.append(.init(name: "list", value: list)) }
        if let tag = query.tag { queryItems.append(.init(name: "tag", value: tag)) }
        
        let task = try webSocketTask(urlString: streamingURL.absoluteString, query: queryItems)
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
    
    internal func webSocketTask(urlString: String, query: [URLQueryItem]) throws -> URLSessionWebSocketTask {
        guard var components = URLComponents(string: urlString) else {
            throw TootSDKError.requiredURLNotSet
        }
        components.queryItems = query
        
        guard let url = components.url else {
            throw TootSDKError.internalError("Unable to create streaming URL with query.")
        }
        
        if let accessToken {
            return session.webSocketTask(with: url, protocols: [accessToken])
        } else {
            return session.webSocketTask(with: url)
        }
    }
}
