//
//  StreamingEvent.swift
//  
//
//  Created by Dale Price on 5/23/24.
//

import Foundation

/// An event sent by the streaming server.
struct StreamingEvent: Sendable {
    /// The timeline or category that the event is relevant to.
    var stream: StreamCategory
    /// The content of the event.
    var event: EventPayload
    
    enum CodingKeys: String, CodingKey {
        case stream
        case event
        case payload
    }
}

extension StreamingEvent: Decodable {
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let stream = StreamCategory(rawValue: try values.decode([String].self, forKey: .stream)) else {
            throw TootSDKError.decodingError("stream")
        }
        self.stream = stream
        
        let eventName = try values.decode(String.self, forKey: .event)
        let payload = try values.decodeIfPresent(String.self, forKey: .payload)
        guard let event = EventPayload(eventName, payload: payload) else {
            throw TootSDKError.decodingError("event or payload")
        }
        self.event = event
    }
}
