//  LocalTimelineQuery.swift
//  Created by Konstantin on 09/03/2023.

import Foundation

/// Specifies the parameters for a local timeline request
public struct LocalTimelineQuery: Hashable, Codable, Sendable {
    public init(onlyMedia: Bool? = nil) {
        self.onlyMedia = onlyMedia
    }

    /// Return only posts with media attachments
    public var onlyMedia: Bool?
}

extension LocalTimelineQuery: TimelineQuery {

    public func getQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        if let onlyMedia {
            queryItems.append(.init(name: "only_media", value: String(onlyMedia)))
        }

        queryItems.append(.init(name: "local", value: String(true)))

        return queryItems
    }
}
