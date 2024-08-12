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
        case error
        case status
    }
}

extension StreamingEvent: Decodable {
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        func throwStreamingError(_ fallback: String) -> TootSDKError {
            let error = try? values.decodeIfPresent(String.self, forKey: .error)
            if let status = try? values.decodeIfPresent(Int.self, forKey: .status) {
                return TootSDKError.streamingError(status: status, error: error ?? "Unknwon")
            }
            else if let error = error {
                return TootSDKError.streamingError(status: 400, error: error)
            }
            else {
                return TootSDKError.decodingError(fallback)
            }
        }
        
        guard let stream = try values.decodeIfPresent([String].self, forKey: .stream),
              let timeline = StreamingTimeline(rawValue: stream) else
        {
            throw throwStreamingError("timeline")
        }
        self.timeline = timeline

        let eventName: String
        let payload: String?
        do {
            eventName = try values.decode(String.self, forKey: .event)
            payload = try values.decodeIfPresent(String.self, forKey: .payload)
        }
        catch {
            throw throwStreamingError("event or payload")
        }
        guard let event = EventContent(eventName, payload: payload) else {
            throw throwStreamingError("event or payload")
        }
        self.event = event
    }
}
