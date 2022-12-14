// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a status posted by an account.
public class Status: Codable, Identifiable {
    public init(id: String,
                uri: String,
                createdAt: Date,
                account: Account,
                content: String? = nil,
                visibility: Status.Visibility,
                sensitive: Bool,
                spoilerText: String,
                mediaAttachments: [Attachment],
                application: TootApplication,
                mentions: [Mention],
                tags: [Tag],
                emojis: [Emoji],
                reblogsCount: Int,
                favouritesCount: Int,
                repliesCount: Int,
                url: String? = nil,
                inReplyToId: String? = nil,
                inReplyToAccountId: String? = nil,
                reblog: Status? = nil,
                poll: Poll? = nil,
                card: Card? = nil,
                language: String? = nil,
                text: String? = nil,
                favourited: Bool? = nil,
                reblogged: Bool? = nil,
                muted: Bool? = nil,
                bookmarked: Bool? = nil,
                pinned: Bool? = nil) {
        self.id = id
        self.uri = uri
        self.createdAt = createdAt
        self.account = account
        self.content = content
        self.visibility = visibility
        self.sensitive = sensitive
        self.spoilerText = spoilerText
        self.mediaAttachments = mediaAttachments
        self.application = application
        self.mentions = mentions
        self.tags = tags
        self.emojis = emojis
        self.reblogsCount = reblogsCount
        self.favouritesCount = favouritesCount
        self.repliesCount = repliesCount
        self.url = url
        self.inReplyToId = inReplyToId
        self.inReplyToAccountId = inReplyToAccountId
        self.reblog = reblog
        self.poll = poll
        self.card = card
        self.language = language
        self.text = text
        self.favourited = favourited
        self.reblogged = reblogged
        self.muted = muted
        self.bookmarked = bookmarked
        self.pinned = pinned
    }

    /// ID of the status in the database.
    public var id: String
    /// URI of the status used for federation.
    public var uri: String
    /// The date when this status was created.
    public var createdAt: Date
    /// The account that authored this status.
    public var account: Account
    /// HTML-encoded status content.
    public var content: String?
    /// Visibility of this status.
    public var visibility: Visibility
    /// Is this status marked as sensitive content?
    public var sensitive: Bool
    /// Subject or summary line, below which status content is collapsed until expanded.
    public var spoilerText: String
    /// Media that is attached to this status.
    public var mediaAttachments: [Attachment]
    /// The application used to post this status.
    public var application: TootApplication?

    /// Mentions of users within the status content.
    public var mentions: [Mention]
    /// Hashtags used within the status content.
    public var tags: [Tag]
    /// Custom emoji to be used when rendering status content.
    public var emojis: [Emoji]
    /// How many boosts this status has received.
    public var reblogsCount: Int
    /// How many favourites this status has received.
    public var favouritesCount: Int
    /// How many replies this status has received.
    public var repliesCount: Int
    /// A link to the status's HTML representation.
    public var url: String?
    /// ID of the status being replied.
    public var inReplyToId: String?
    /// ID of the account being replied to.
    public var inReplyToAccountId: String?
    /// The status being reblogged.
    public var reblog: Status?
    /// The poll attached to the status.
    public var poll: Poll?
    /// Preview card for links included within status content.
    public var card: Card?
    /// Primary language of this status.
    public var language: String?
    /// Plain-text source of a status. Returned instead of content when status is deleted so the user
    /// may redraft from the source text without the client having to reverse-engineer the original text from the HTML content.
    public var text: String?
    /// Have you favourited this status?
    public var favourited: Bool?
    /// Have you boosted this status?
    public var reblogged: Bool?
    /// Have you muted notifications for this status's conversation?
    public var muted: Bool?
    /// Have you bookmarked this status?
    public var bookmarked: Bool?
    /// Have you pinned this status? Only appears if the status is pinnable.
    public var pinned: Bool?

    public enum Visibility: String, Codable, CaseIterable {
        /// Visible to everyone, shown in public timelines.
        case `public`
        /// Visible to public, but not included in public timelines.
        case unlisted
        /// Visible to followers only, and to any mentioned users.
        case `private`
        /// Visible only to mentioned users.
        case direct
    }
}

extension Status: Hashable {
    public static func == (lhs: Status, rhs: Status) -> Bool {
        lhs.id == rhs.id
        && lhs.uri == rhs.uri
        && lhs.createdAt == rhs.createdAt
        && lhs.account == rhs.account
        && lhs.content == rhs.content
        && lhs.visibility == rhs.visibility
        && lhs.sensitive == rhs.sensitive
        && lhs.spoilerText == rhs.spoilerText
        && lhs.mediaAttachments == rhs.mediaAttachments
        && lhs.mentions == rhs.mentions
        && lhs.tags == rhs.tags
        && lhs.emojis == rhs.emojis
        && lhs.reblogsCount == rhs.reblogsCount
        && lhs.favouritesCount == rhs.favouritesCount
        && lhs.repliesCount == rhs.repliesCount
        && lhs.application == rhs.application
        && lhs.url == rhs.url
        && lhs.inReplyToId == rhs.inReplyToId
        && lhs.inReplyToAccountId == rhs.inReplyToAccountId
        && lhs.reblog == rhs.reblog
        && lhs.poll == rhs.poll
        && lhs.card == rhs.card
        && lhs.language == rhs.language
        && lhs.text == rhs.text
        && lhs.favourited == rhs.favourited
        && lhs.reblogged == rhs.reblogged
        && lhs.muted == rhs.muted
        && lhs.bookmarked == rhs.bookmarked
        && lhs.pinned == rhs.pinned
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uri)
        hasher.combine(createdAt)
        hasher.combine(account)
        hasher.combine(content)
        hasher.combine(visibility)
        hasher.combine(sensitive)
        hasher.combine(spoilerText)
        hasher.combine(mediaAttachments)
        hasher.combine(mentions)
        hasher.combine(tags)
        hasher.combine(emojis)
        hasher.combine(reblogsCount)
        hasher.combine(favouritesCount)
        hasher.combine(repliesCount)
        hasher.combine(application)
        hasher.combine(url)
        hasher.combine(inReplyToId)
        hasher.combine(inReplyToAccountId)
        hasher.combine(reblog)
        hasher.combine(poll)
        hasher.combine(card)
        hasher.combine(language)
        hasher.combine(text)
        hasher.combine(favourited)
        hasher.combine(reblogged)
        hasher.combine(muted)
        hasher.combine(bookmarked)
        hasher.combine(pinned)
    }
}
