//
//  StreamQuery.swift
//
//
//  Created by Dale Price on 5/23/24.
//

import Foundation

/// Payload that can be sent over WebSocket to provide query parameters to the streaming API.
public struct StreamQuery: Codable, Sendable, Equatable {
    public enum Action: String, RawRepresentable, Codable, Sendable {
        case subscribe = "subscribe"
        case unsubscribe = "unsubscribe"
    }
    
    /// The type of action we wish to perform.
    var type: Action
    /// The stream to watch for events.
    var stream: String
    /// When ``stream`` is set to `list`, specifies the list ID.
    var list: String?
    /// When ``stream`` is set to `hashtag` or `hashtag:local`, specifies the hashtag name.
    var tag: String?
    
    internal init(type: Action, stream: String, list: String? = nil, tag: String? = nil) {
        self.type = type
        self.stream = stream
        self.list = list
        self.tag = tag
    }
    
    public init(_ action: Action, stream: StreamCategory) {
        self.type = action
        let streamParams = stream.rawValue
        self.stream = streamParams[0]
        if (self.stream == "hashtag" || self.stream == "hashtag:local") && streamParams.count == 2 {
            self.tag = streamParams[1]
        } else if self.stream == "list" && streamParams.count == 2 {
            self.list = streamParams[1]
        }
    }
}
