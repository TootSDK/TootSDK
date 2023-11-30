// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents an announcement set by an administrator.
public struct Announcement: Codable, Hashable, Identifiable {
    public init(id: String,
                content: String,
                publishedAt: Date? = nil,
                published: Bool? = nil,
                allDay: Bool,
                createdAt: Date? = nil,
                updatedAt: Date? = nil,
                read: Bool? = nil,
                mentions: [Announcement.Account],
                statuses: [Announcement.Status],
                tags: [Tag],
                emojis: [Emoji],
                reactions: [AnnouncementReaction],
                startsAt: Date? = nil,
                endsAt: Date? = nil) {
        self.id = id
        self.content = content
        self.publishedAt = publishedAt
        self.published = published
        self.allDay = allDay
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.read = read
        self.mentions = mentions
        self.statuses = statuses
        self.tags = tags
        self.emojis = emojis
        self.reactions = reactions
        self.startsAt = startsAt
        self.endsAt = endsAt
    }

    /// The announcement id.
    public let id: String
    /// The content of the announcement.
    public let content: String
    /// The date the post was published
    public let publishedAt: Date?
    /// Whether the announcement is currently active.
    public let published: Bool?
    /// Whether the announcement should start and end on dates only instead of datetimes. Will be false if there is no starts_at or ends_at time.
    public let allDay: Bool
    /// Whether the announcement has a start/end time.
    public let createdAt: Date?
    /// When the announcement was last updated.
    public let updatedAt: Date?
    /// Whether the announcement has been read by the user.
    public let read: Bool?
    /// Accounts mentioned in the announcement text.
    public let mentions: [Announcement.Account]
    /// Statuses mentioned in the announcement text.
    public let statuses: [Announcement.Status]
    /// Tags linked in the announcement text.
    public let tags: [Tag]
    /// Custom emoji used in the announcement text.
    public let emojis: [Emoji]
    /// Emoji reactions attached to the announcement.
    public let reactions: [AnnouncementReaction]
    ///  When the future announcement will start.
    public let startsAt: Date?
    ///  When the future announcement will end.
    public let endsAt: Date?

    public struct Account: Codable, Hashable, Identifiable {
        public init(id: String, username: String, url: String, acct: String) {
            self.id = id
            self.username = username
            self.url = url
            self.acct = acct
        }

        /// The account ID of the mentioned user.
        public var id: String
        /// The username of the mentioned user.
        public var username: String
        /// The location of the mentioned user’s profile.
        public var url: String
        /// The webfinger acct: URI of the mentioned user.
        /// Equivalent to username for local users, or username@domain for remote users.
        public var acct: String
    }

    public struct Status: Codable, Hashable, Identifiable {
        public init(id: String, url: String) {
            self.id = id
            self.url = url
        }

        /// The ID of an attached Status in the database.
        public var id: String
        /// The URL of an attached Status.
        public var url: String
    }
}
