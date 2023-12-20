//
//  UpdateCredentialsParams.swift
//
//
//  Created by Philip Chu on 6/26/23.
//

import Foundation

public struct UpdateCredentialsParams: Codable {
    /// The display name to use for the profile.
    public var displayName: String?
    /// The account bio.
    public var note: String?
    /// Avatar image encoded using multipart/form-data
    public var avatar: Data?
    public var avatarMimeType: String?
    /// Header image encoded using multipart/form-data
    public var header: Data?
    public var headerMimeType: String?
    /// Whether manual approval of follow requests is required.
    public var locked: Bool?
    /// Whether the account has a bot flag.
    public var bot: Bool?
    /// Whether he account should be shown in the profile directory.
    public var discoverable: Bool?
    /// Additional metadata attached to a profile as name-value pairs
    public let fieldsAttributes: [String: Field]?
    /// An extra entity to be used with API methods to verify credentials and update credentials
    public let source: Source?

    public init(
        displayName: String? = nil, note: String? = nil, avatar: Data? = nil, avatarMimeType: String? = nil, header: Data? = nil,
        headerMimeType: String? = nil, locked: Bool? = nil, bot: Bool? = nil, discoverable: Bool? = nil, fieldsAttributes: [String: Field]? = nil,
        source: Source? = nil
    ) {
        self.displayName = displayName
        self.note = note
        self.avatar = avatar
        self.avatarMimeType = avatarMimeType
        self.header = header
        self.headerMimeType = headerMimeType
        self.locked = locked
        self.bot = bot
        self.discoverable = discoverable
        self.fieldsAttributes = fieldsAttributes
        self.source = source
    }

    /// Represents a profile field as a name-value pair
    public struct Field: Codable, Hashable, Sendable {
        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }

        /// The key of a given field's key-value pair.
        public var name: String
        /// The value associated with the name key.
        public var value: String
    }

    public struct Source: Codable, Hashable, Sendable {
        public init(privacy: Post.Visibility? = nil, sensitive: Bool? = nil, language: String? = nil) {
            self.privacy = privacy
            self.sensitive = sensitive
            self.language = language
        }
        /// The default post privacy to be used for new posts.
        public var privacy: Post.Visibility?
        /// Whether new posts should be marked sensitive by default.
        public var sensitive: Bool?
        ///  The default posting language for new posts.
        public var language: String?
    }
}
