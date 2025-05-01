// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Filter: Codable, Hashable, Identifiable {
    public enum Context: String, Codable, Sendable, Hashable {
        /// home timeline and lists
        case home
        /// notifications timeline
        case notifications
        /// public timelines
        case `public`
        /// expanded thread of a detailed post
        case thread
        /// when viewing a profile
        case account
    }

    public enum Action: String, Codable, Sendable, Hashable {
        /// show a warning that identifies the matching filter by title, and allow the user to expand the filtered post. This is the default (and unknown values should be treated as equivalent to warn).
        case warn
        /// do not show this post if it is received
        case hide
        /// hide/blur media attachments with a warning identifying the matching filter by ``Filter/title``
        case blur
    }

    /// The ID of the Filter in the database.
    public var id: String
    /// A title given by the user to name the filter.
    public var title: String
    /// The contexts in which the filter should be applied.
    public var context: [Context]
    /// When the filter should no longer be applied.
    public var expiresAt: Date?
    /// The action to be taken when a post matches this filter.
    public var filterAction: Action
    /// The keywords grouped under this filter.
    public var keywords: [FilterKeyword]
    /// The posts grouped under this filter.
    public var statuses: [FilterStatus]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case context
        case expiresAt
        case filterAction
        case keywords
        case statuses  // posts = "statuses"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.context = try container.decode([Context].self, forKey: .context)
        self.expiresAt = try? container.decodeIfPresent(Date.self, forKey: .expiresAt)
        self.filterAction = try container.decode(Action.self, forKey: .filterAction)
        // not returned when part of FilterResult
        self.keywords = (try? container.decodeIfPresent([FilterKeyword].self, forKey: .keywords)) ?? []
        // not returned when part of FilterResult
        self.statuses = (try? container.decodeIfPresent([FilterStatus].self, forKey: .statuses)) ?? []
    }
}

extension Filter.Context: Identifiable {
    public var id: Self { self }
}
