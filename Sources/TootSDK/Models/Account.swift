// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a user  and their associated profile.
public class Account: Codable, Identifiable {
    public init(id: String, username: String? = nil, acct: String, url: String, displayName: String? = nil, note: String, avatar: String, avatarStatic: String? = nil, header: String, headerStatic: String, locked: Bool, emojis: [Emoji], discoverable: Bool? = nil, createdAt: Date, lastPostAt: Date? = nil, postsCount: Int, followersCount: Int, followingCount: Int, moved: Account? = nil, suspended: Bool? = nil, limited: Bool? = nil, fields: [TootField], bot: Bool? = nil, source: TootSource? = nil) {
        self.id = id
        self.username = username
        self.acct = acct
        self.url = url
        self.displayName = displayName
        self.note = note
        self.avatar = avatar
        self.avatarStatic = avatarStatic
        self.header = header
        self.headerStatic = headerStatic
        self.locked = locked
        self.emojis = emojis
        self.discoverable = discoverable
        self.createdAt = createdAt
        self.lastPostAt = lastPostAt
        self.postsCount = postsCount
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.moved = moved
        self.suspended = suspended
        self.limited = limited
        self.fields = fields
        self.bot = bot
        self.source = source
    }
    
    /// The account id.
    public var id: String
    /// The username of the account, not including domain.
    public var username: String?
    /// The Webfinger account URI. Equal to username for local users, or username@domain for remote users.
    public var acct: String
    /// The location of the user's profile page
    public var url: String
    /// The profile's display name.
    public var displayName: String?
    /// The profile's bio / description
    public var note: String
    /// An image icon that is shown next to posts and in the profile
    public var avatar: String
    /// A static version of the avatar.
    public var avatarStatic: String?
    /// An image banner that is shown above the profile and in profile cards
    public var header: String
    /// A static version of the header
    public var headerStatic: String
    /// Whether the account manually approves follow requests
    public var locked: Bool
    /// Custom emoji entities to be used when rendering the profile. If none, an empty array will be returned
    public var emojis: [Emoji]
    /// Whether the account has opted into discovery features such as the profile directory
    public var discoverable: Bool?
    /// When the account was created
    public var createdAt: Date
    /// When the most recent post was posted
    public var lastPostAt: Date?
    /// How many posts are attached to this account
    public var postsCount: Int
    /// The reported followers of this profile
    public var followersCount: Int
    /// The reported follows of this profile
    public var followingCount: Int
    /// Indicates that the profile is currently inactive and that its user has moved to a new account
    public var moved: Account?
    /// An extra attribute returned only when an account is suspended.
    public var suspended: Bool?
    /// An extra attribute returned only when an account is silenced. If true, indicates that the account should be hidden behing a warning screen.
    public var limited: Bool?
    /// Additional metadata attached to a profile as name-value pairs
    public var fields: [TootField]
    /// A presentational flag.
    /// Indicates that the account may perform automated actions, may not be monitored, or identifies as a robot
    public var bot: Bool?
    /// An extra entity to be used with API methods to verify credentials and update credentials
    public var source: TootSource?
}

public extension Account {
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case acct
        case url
        case displayName
        case note
        case avatar
        case avatarStatic
        case header
        case headerStatic
        case locked
        case emojis
        case discoverable
        case createdAt
        case lastPostAt = "lastStatusAt"
        case postsCount = "statusesCount"
        case followersCount
        case followingCount
        case moved
        case suspended
        case limited
        case fields
        case bot
        case source
    }
}

extension Account: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(username)
        hasher.combine(acct)
        hasher.combine(url)
        hasher.combine(displayName)
        hasher.combine(note)
        hasher.combine(avatar)
        hasher.combine(avatarStatic)
        hasher.combine(header)
        hasher.combine(headerStatic)
        hasher.combine(locked)
        hasher.combine(emojis)
        hasher.combine(discoverable)
        hasher.combine(createdAt)
        hasher.combine(lastPostAt)
        hasher.combine(postsCount)
        hasher.combine(followersCount)
        hasher.combine(followingCount)
        hasher.combine(moved)
        hasher.combine(suspended)
        hasher.combine(limited)
        hasher.combine(fields)
        hasher.combine(bot)
        hasher.combine(source)
    }
    
    public static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}

extension Account: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Account with id: \(id)"
    }
}
