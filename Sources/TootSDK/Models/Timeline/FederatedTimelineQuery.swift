//  FederatedTimelineQuery.swift
//  Created by Konstantin on 09/03/2023.

import Foundation

/// Specifies the parameters for a federated timeline request
public struct FederatedTimelineQuery: Codable, Sendable {
    public init(onlyMedia: Bool? = nil) {
        self.onlyMedia = onlyMedia
    }

    /// Return only statuses with media attachments
    public var onlyMedia: Bool?
}

extension FederatedTimelineQuery: TimelineQuery {

    public func getQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        if let onlyMedia = onlyMedia {
            queryItems.append(.init(name: "only_media", value: String(onlyMedia)))
        }

        return queryItems
    }

}
