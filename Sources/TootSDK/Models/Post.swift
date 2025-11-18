// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a post posted by an account.
public class Post: Codable, Identifiable, @unchecked Sendable {
    public init(
        id: String,
        uri: String,
        createdAt: Date,
        account: Account,
        content: String? = nil,
        visibility: Post.Visibility,
        quoteApproval: QuoteApproval? = nil,
        sensitive: Bool,
        spoilerText: String,
        mediaAttachments: [MediaAttachment],
        application: TootApplication?,
        mentions: [Mention],
        tags: [Tag],
        emojis: [Emoji],
        repostsCount: Int,
        quotesCount: Int? = nil,
        favouritesCount: Int,
        repliesCount: Int,
        url: String? = nil,
        inReplyToId: String? = nil,
        inReplyToAccountId: String? = nil,
        repost: Post? = nil,
        poll: Poll? = nil,
        card: Card? = nil,
        language: String? = nil,
        text: String? = nil,
        editedAt: Date? = nil,
        favourited: Bool? = nil,
        reposted: Bool? = nil,
        muted: Bool? = nil,
        bookmarked: Bool? = nil,
        pinned: Bool? = nil,
        filtered: [FilterResult]? = nil,
        quote: Quote? = nil
    ) {
        self.id = id
        self.uri = uri
        self.createdAt = createdAt
        self.account = account
        self.content = content
        self.visibility = .some(visibility)
        self.quoteApproval = quoteApproval
        self.sensitive = sensitive
        self.spoilerText = spoilerText
        self.mediaAttachments = mediaAttachments
        self.application = application
        self.mentions = mentions
        self.tags = tags
        self.emojis = emojis
        self.repostsCount = repostsCount
        self.quotesCount = quotesCount
        self.favouritesCount = favouritesCount
        self.repliesCount = repliesCount
        self.url = url
        self.inReplyToId = inReplyToId
        self.inReplyToAccountId = inReplyToAccountId
        self.repost = repost
        self.poll = poll
        self.card = card
        self.language = language
        self.text = text
        self.editedAt = editedAt
        self.favourited = favourited
        self.reposted = reposted
        self.muted = muted
        self.bookmarked = bookmarked
        self.pinned = pinned
        self.filtered = filtered
        self.quote = quote
    }

    /// ID of the post in the database.
    public var id: String
    /// URI of the post used for federation.
    public var uri: String
    /// The date when this post was created.
    public var createdAt: Date
    /// The account that authored this post.
    public var account: Account
    /// HTML-encoded post content.
    public var content: String?
    /// Visibility of this post.
    public var visibility: OpenEnum<Visibility>
    /// Summary of a status' quote approval policy and how it applies to the requesting user.
    public var quoteApproval: QuoteApproval?
    /// Is this post marked as sensitive content?
    public var sensitive: Bool
    /// Subject or summary line, below which post content is collapsed until expanded.
    public var spoilerText: String
    /// Media that is attached to this post.
    public var mediaAttachments: [MediaAttachment]
    /// The application used to post this post.
    public var application: TootApplication?

    /// Mentions of users within the post content.
    public var mentions: [Mention]
    /// Hashtags used within the post content.
    public var tags: [Tag]
    /// Custom emoji to be used when rendering post content.
    public var emojis: [Emoji]
    /// How many reposts this post has received.
    public var repostsCount: Int
    /// How many quotes this post has received.
    public var quotesCount: Int?
    /// How many favourites this post has received.
    public var favouritesCount: Int
    /// How many replies this post has received.
    public var repliesCount: Int
    /// A link to the post's HTML representation.
    public var url: String?
    /// ID of the post being replied.
    public var inReplyToId: String?
    /// ID of the account being replied to.
    public var inReplyToAccountId: String?
    /// The post being reposted.
    public var repost: Post?
    /// The poll attached to the post.
    public var poll: Poll?
    /// Preview card for links included within post content.
    public var card: Card?
    /// Primary language of this post.
    public var language: String?
    /// Plain-text source of a post. Returned instead of content when post is deleted so the user
    /// may redraft from the source text without the client having to reverse-engineer the original text from the HTML content.
    public var text: String?
    /// The date when the post was last edited.
    public var editedAt: Date?
    /// Have you favourited this post?
    public var favourited: Bool?
    /// Have you reposted this post?
    public var reposted: Bool?
    /// Have you muted notifications for this post's conversation?
    public var muted: Bool?
    /// Have you bookmarked this post?
    public var bookmarked: Bool?
    /// Have you pinned this post? Only appears if the post is pinnable.
    public var pinned: Bool?
    /// If the current token has an authorized user: The filter and keywords that matched this post.
    public var filtered: [FilterResult]?
    /// Information about the post being quoted, if any.
    public var quote: Quote?

    public enum Visibility: String, Codable, CaseIterable, Sendable {
        /// Visible to everyone, shown in public timelines.
        case `public`
        /// Visible to public, but not included in public timelines.
        case unlisted
        /// Visible to followers only, and to any mentioned users.
        case `private`
        /// Visible only to mentioned users.
        case direct
    }

    enum CodingKeys: String, CodingKey {
        case id
        case uri
        case createdAt
        case account
        case content
        case visibility
        case quoteApproval
        case sensitive
        case spoilerText
        case mediaAttachments
        case application
        case mentions
        case tags
        case emojis
        case repostsCount = "reblogsCount"
        case quotesCount = "quotes_count"
        case favouritesCount
        case repliesCount
        case url
        case inReplyToId
        case inReplyToAccountId
        case repost = "reblog"
        case poll
        case card
        case language
        case text
        case editedAt
        case favourited
        case reposted = "reblogged"
        case muted
        case bookmarked
        case pinned
        case filtered
        case quote
    }
}

extension Post: Hashable {
    public static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
            && lhs.uri == rhs.uri
            && lhs.createdAt == rhs.createdAt
            && lhs.account == rhs.account
            && lhs.content == rhs.content
            && lhs.visibility == rhs.visibility
            && lhs.quoteApproval == rhs.quoteApproval
            && lhs.sensitive == rhs.sensitive
            && lhs.spoilerText == rhs.spoilerText
            && lhs.mediaAttachments == rhs.mediaAttachments
            && lhs.mentions == rhs.mentions
            && lhs.tags == rhs.tags
            && lhs.emojis == rhs.emojis
            && lhs.repostsCount == rhs.repostsCount
            && lhs.quotesCount == rhs.quotesCount
            && lhs.favouritesCount == rhs.favouritesCount
            && lhs.repliesCount == rhs.repliesCount
            && lhs.application == rhs.application
            && lhs.url == rhs.url
            && lhs.inReplyToId == rhs.inReplyToId
            && lhs.inReplyToAccountId == rhs.inReplyToAccountId
            && lhs.repost == rhs.repost
            && lhs.poll == rhs.poll
            && lhs.card == rhs.card
            && lhs.language == rhs.language
            && lhs.text == rhs.text
            && lhs.editedAt == rhs.editedAt
            && lhs.favourited == rhs.favourited
            && lhs.reposted == rhs.reposted
            && lhs.muted == rhs.muted
            && lhs.bookmarked == rhs.bookmarked
            && lhs.pinned == rhs.pinned
            && lhs.filtered == rhs.filtered
            && lhs.quote == rhs.quote
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uri)
        hasher.combine(createdAt)
        hasher.combine(account)
        hasher.combine(content)
        hasher.combine(visibility)
        hasher.combine(quoteApproval)
        hasher.combine(sensitive)
        hasher.combine(spoilerText)
        hasher.combine(mediaAttachments)
        hasher.combine(mentions)
        hasher.combine(tags)
        hasher.combine(emojis)
        hasher.combine(repostsCount)
        hasher.combine(quotesCount)
        hasher.combine(favouritesCount)
        hasher.combine(repliesCount)
        hasher.combine(application)
        hasher.combine(url)
        hasher.combine(inReplyToId)
        hasher.combine(inReplyToAccountId)
        hasher.combine(repost)
        hasher.combine(poll)
        hasher.combine(card)
        hasher.combine(language)
        hasher.combine(text)
        hasher.combine(editedAt)
        hasher.combine(favourited)
        hasher.combine(reposted)
        hasher.combine(muted)
        hasher.combine(bookmarked)
        hasher.combine(pinned)
        hasher.combine(filtered)
        hasher.combine(quote)
    }
}

extension Post {

    /// Convenience var for which post to display. This can be used by clients instead of if/then checking the repost value itself
    public var displayPost: Post {
        return self.repost ?? self
    }

    /// Indicates whether displayPost is a repost or not
    public var displayingRepost: Bool {
        return self.repost != nil
    }

}
