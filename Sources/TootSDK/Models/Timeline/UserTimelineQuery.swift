//  UserTimelineQuery.swift
//  Created by Łukasz Rutkowski on 13/03/2023.

import Foundation

/// Specifies the parameters for a user posts timeline request
public struct UserTimelineQuery: Sendable {

    public init(
        userId: String, onlyMedia: Bool? = nil, excludeReplies: Bool? = nil, excludeBoosts: Bool? = nil, pinned: Bool? = nil, tagged: String? = nil
    ) {
        self.userId = userId
        self.onlyMedia = onlyMedia
        self.excludeReplies = excludeReplies
        self.excludeBoosts = excludeBoosts
        self.pinned = pinned
        self.tagged = tagged
    }

    /// The id of the user
    public var userId: String

    /// Return only posts with media attachments
    public var onlyMedia: Bool?

    /// Filter out posts in reply to a different account
    public var excludeReplies: Bool?

    /// Filter out boosts
    public var excludeBoosts: Bool?

    /// Filter for pinned posts only
    public var pinned: Bool?

    /// Filter for posts using a specific hashtag
    public var tagged: String?
}

extension UserTimelineQuery: TimelineQuery {

    public func getQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        if let onlyMedia {
            queryItems.append(.init(name: "only_media", value: String(onlyMedia)))
        }

        if let excludeReplies {
            queryItems.append(.init(name: "exclude_replies", value: String(excludeReplies)))
        }

        if let excludeBoosts {
            queryItems.append(.init(name: "exclude_reblogs", value: String(excludeBoosts)))
        }

        if let pinned {
            queryItems.append(.init(name: "pinned", value: String(pinned)))
        }

        if let tagged {
            queryItems.append(.init(name: "tagged", value: tagged))
        }

        return queryItems
    }

}
