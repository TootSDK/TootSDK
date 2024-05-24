//
//  StreamingEvent.swift
//  
//
//  Created by Dale Price on 5/23/24.
//

import Foundation

/// An event sent by the streaming server.
public struct StreamingEvent: Sendable {
    /// The timeline or category that the event is relevant to.
    var timeline: StreamingTimeline
    /// The content of the event.
    var event: EventContent
    
    enum CodingKeys: String, CodingKey {
        case stream
        case event
        case payload
    }
}

extension StreamingEvent: Decodable {
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let timeline = StreamingTimeline(rawValue: try values.decode([String].self, forKey: .stream)) else {
            throw TootSDKError.decodingError("timeline")
        }
        self.timeline = timeline
        
        let eventName = try values.decode(String.self, forKey: .event)
        let payload = try values.decodeIfPresent(String.self, forKey: .payload)
        guard let event = EventContent(eventName, payload: payload) else {
            throw TootSDKError.decodingError("event or payload")
        }
        self.event = event
    }
}
