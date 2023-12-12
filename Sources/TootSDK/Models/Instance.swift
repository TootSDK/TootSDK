// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// General information about an instance
public struct Instance: Codable, Hashable {
    public init(
        uri: String? = nil,
        title: String? = nil,
        description: String? = nil,
        shortDescription: String? = nil,
        email: String? = nil,
        version: String,
        languages: [String]? = nil,
        registrations: Bool? = nil,
        approvalRequired: Bool? = nil,
        invitesEnabled: Bool? = nil,
        urls: Instance.InstanceURLs,
        stats: Instance.Stats,
        thumbnail: String? = nil,
        configuration: Configuration? = nil,
        contactAccount: Account? = nil,
        rules: [InstanceRule]? = nil
    ) {
        self.uri = uri
        self.title = title
        self.description = description
        self.shortDescription = shortDescription
        self.email = email
        self.version = version
        self.languages = languages
        self.registrations = registrations
        self.approvalRequired = approvalRequired
        self.invitesEnabled = invitesEnabled
        self.urls = urls
        self.stats = stats
        self.thumbnail = thumbnail
        self.configuration = configuration
        self.contactAccount = contactAccount
        self.rules = rules
    }

    /// The domain name of the instance.
    public var uri: String?
    /// The title of the website.
    public var title: String?
    /// Admin-defined description of the Fediverse site.
    public var description: String?
    /// A shorter description defined by the admin.
    public var shortDescription: String?
    /// An email that may be contacted for any inquiries.
    public var email: String?
    /// The version of  the server installed on the instance.
    public var version: String
    /// Primary languages of the website and its staff.
    public var languages: [String]?
    /// Whether registrations are enabled.
    public var registrations: Bool?
    /// Whether registrations require moderator approval.
    public var approvalRequired: Bool?
    /// Whether invites are enabled.
    public var invitesEnabled: Bool?
    /// URLs of interest for clients apps.
    public var urls: InstanceURLs?
    /// Statistics about how much information the instance contains.
    public var stats: Stats
    /// Banner image for the website.
    public var thumbnail: String?
    /// Configured values and limits for this instance.
    public var configuration: Configuration?
    /// A user that can be contacted, as an alternative to email.
    public var contactAccount: Account?
    /// An itemized list of rules for users of the instance.
    public var rules: [InstanceRule]?

    public struct InstanceURLs: Codable, Hashable {
        /// Websockets address for push streaming. String (URL).
        public var streamingApi: String?
    }

    public struct Stats: Codable, Hashable {
        /// Users registered on this instance. Number.
        public var userCount: Int?
        /// Posts authored by users on instance. Number.
        public var postCount: Int?
        /// Domains federated with this instance. Number.
        public var domainCount: Int?

        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case userCount
            case postCount = "statusCount"
            case domainCount
        }
    }

    public struct Configuration: Codable, Hashable {
        /// Limits related to accounts.
        public var accounts: Accounts?
        /// Limits related to authoring posts.
        public var posts: Posts?
        /// Hints for which attachments will be accepted.
        public var mediaAttachments: MediaAttachments?
        /// Limits related to polls.
        public var polls: Polls?

        // swiftlint:disable nesting

        enum CodingKeys: String, CodingKey {
            case accounts
            case posts = "statuses"
            case mediaAttachments
            case polls
        }

        public struct Accounts: Codable, Hashable {
            /// The maximum number of featured tags allowed for each account.
            public var maxFeaturedTags: Int?
        }

        public struct Posts: Codable, Hashable {
            /// The maximum number of allowed characters per post.
            public var maxCharacters: Int?
            /// The maximum number of media attachments that can be added to a post.
            public var maxMediaAttachments: Int?
            /// Each URL in a post will be assumed to be exactly this many characters.
            public var charactersReservedPerUrl: Int?
        }

        public struct MediaAttachments: Codable, Hashable {
            /// Contains MIME types that can be uploaded.
            public var supportedMimeTypes: [String]?
            /// The maximum size of any uploaded image, in bytes.
            public var imageSizeLimit: Int?
            /// The maximum number of pixels (width times height) for image uploads.
            public var imageMatrixLimit: Int?
            /// The maximum size of any uploaded video, in bytes.
            public var videoSizeLimit: Int?
            /// The maximum frame rate for any uploaded video.
            public var videoFrameRateLimit: Int?
            /// The maximum number of pixels (width times height) for video uploads.
            public var videoMatrixLimit: Int?
        }

        public struct Polls: Codable, Hashable {
            /// Each poll is allowed to have up to this many options.
            public var maxOptions: Int?
            /// Each poll option is allowed to have this many characters.
            public var maxCharactersPerOption: Int?
            /// The shortest allowed poll duration, in seconds.
            public var minExpiration: Int?
            /// The longest allowed poll duration, in seconds.
            public var maxExpiration: Int?
        }

        // swiftlint:enable nesting
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uri = try? container.decodeIfPresent(String.self, forKey: .uri)
        self.title = try? container.decodeIfPresent(String.self, forKey: .title)
        self.description = try? container.decodeIfPresent(String.self, forKey: .description)
        self.shortDescription = try? container.decodeIfPresent(String.self, forKey: .shortDescription)
        self.email = try? container.decodeIfPresent(String.self, forKey: .email)
        self.version = try container.decode(String.self, forKey: .version)
        self.languages = try? container.decodeIfPresent([String].self, forKey: .languages)
        self.registrations = try? container.decodeIfPresent(Bool.self, forKey: .registrations)
        self.approvalRequired = try? container.decodeIfPresent(Bool.self, forKey: .approvalRequired)
        self.invitesEnabled = try? container.decodeIfPresent(Bool.self, forKey: .invitesEnabled)
        self.urls = try? container.decodeIfPresent(Instance.InstanceURLs.self, forKey: .urls)
        self.stats = try container.decode(Stats.self, forKey: .stats)
        self.thumbnail = try? container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.configuration = try? container.decodeIfPresent(Configuration.self, forKey: .configuration)
        // also handles some friendica instances returning []
        self.contactAccount = try? container.decodeIfPresent(Account.self, forKey: .contactAccount)
        self.rules = try? container.decodeIfPresent([InstanceRule].self, forKey: .rules)
    }
}

public extension Instance {
    var majorVersion: Int? {
        guard let majorVersionString = version.split(separator: ".").first else { return nil }

        return Int(majorVersionString)
    }

    var minorVersion: Int? {
        let versionComponents = version.split(separator: ".")

        guard versionComponents.count > 1 else { return nil }

        return Int(versionComponents[1])
    }

    var patchVersion: String? {
        let versionComponents = version.split(separator: ".")

        guard versionComponents.count > 2 else { return nil }

        return String(versionComponents[2])
    }

    var canShowProfileDirectory: Bool {
        guard let majorVersion = majorVersion else { return false }

        return majorVersion >= 3
    }
}

public extension Instance {
    var flavour: TootSDKFlavour {
        if version.lowercased().contains("pleroma") {
            return .pleroma
        }
        if version.lowercased().contains("pixelfed") {
            return .pixelfed
        }
        if version.lowercased().contains("friendica") {
            return .friendica
        }
        if version.lowercased().contains("akkoma") {
            return .akkoma
        }
        if version.lowercased().contains("firefish") {
            return .firefish
        }
        return .mastodon
    }
}
