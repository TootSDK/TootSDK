// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents an emoji reaction to an Announcement.
public struct AnnouncementReaction: Codable, Hashable {
    public init(name: String, count: Int, me: Bool, url: String? = nil, staticUrl: String? = nil) {
        self.name = name
        self.count = count
        self.me = me
        self.url = url
        self.staticUrl = staticUrl
    }

    /// The emoji used for the reaction. Either a unicode emoji, or a custom emoji's shortcode.
    public var name: String
    /// The total number of users who have added this reaction.
    public var count: Int
    /// Whether the authorized user has added this reaction to the announcement.
    public var me: Bool
    /// A link to the custom emoji.
    public var url: String?
    /// A link to a non-animated version of the custom emoji.
    public var staticUrl: String?
}
