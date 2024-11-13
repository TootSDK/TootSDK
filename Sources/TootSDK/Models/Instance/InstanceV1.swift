// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// General information about an instance
public struct InstanceV1: Codable, Hashable {
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
        urls: InstanceV1.InstanceURLs,
        stats: InstanceV1.Stats,
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

    public typealias Configuration = InstanceConfiguration

    public struct InstanceURLs: Codable, Hashable, Sendable {
        /// Websockets address for push streaming. String (URL).
        public var streamingApi: String?
    }

    public struct Stats: Codable, Hashable, Sendable {
        /// Users registered on this instance. Number.
        public var userCount: Int?
        /// Posts authored by users on instance. Number.
        public var postCount: Int?
        /// Domains federated with this instance. Number.
        public var domainCount: Int?

        enum CodingKeys: String, CodingKey {
            case userCount
            case postCount = "statusCount"
            case domainCount
        }

        public init(from decoder: Decoder) throws {
            // Custom decoder handles the possibility for count values to be provided as String
            // e.g. Pixelfed in v0.12.3 https://github.com/TootSDK/TootSDK/issues/300

            let container = try decoder.container(keyedBy: CodingKeys.self)
            // userCount
            if let intValue = try? container.decode(Int.self, forKey: .userCount) {
                self.userCount = intValue
            } else if let stringValue = try? container.decode(String.self, forKey: .userCount) {
                self.userCount = Int(stringValue)
            } else {
                self.userCount = nil
            }
            // postCount
            if let intValue = try? container.decode(Int.self, forKey: .postCount) {
                self.postCount = intValue
            } else if let stringValue = try? container.decode(String.self, forKey: .postCount) {
                self.postCount = Int(stringValue)
            } else {
                self.postCount = nil
            }

            // domainCount
            if let intValue = try? container.decode(Int.self, forKey: .domainCount) {
                self.domainCount = intValue
            } else if let stringValue = try? container.decode(String.self, forKey: .domainCount) {
                self.domainCount = Int(stringValue)
            } else {
                self.domainCount = nil
            }
        }
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
        self.urls = try? container.decodeIfPresent(InstanceV1.InstanceURLs.self, forKey: .urls)
        self.stats = try container.decode(Stats.self, forKey: .stats)
        self.thumbnail = try? container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.configuration = try? container.decodeIfPresent(Configuration.self, forKey: .configuration)
        // also handles some friendica instances returning []
        self.contactAccount = try? container.decodeIfPresent(Account.self, forKey: .contactAccount)
        self.rules = try? container.decodeIfPresent([InstanceRule].self, forKey: .rules)
    }
}

extension InstanceV1: Instance {
    public var domain: String? { uri }
    public var thumbnailURL: String? { thumbnail }
    public var registrationsEnabled: Bool? { registrations }
    public var streamingURL: String? { urls?.streamingApi }
}

extension InstanceV1 {
    /// Get the instance's information in the format of an ``InstanceV2``.
    ///
    /// Because ``InstanceV1`` does not contain all of the information that ``InstanceV2`` does, v2-exclusive fields will be left as `nil`.
    ///
    /// Information that is only present in v1, such as ``invitesEnabled`` and ``Stats-swift.struct``, will not be present in the v2 representation.
    ///
    /// Information that is represented differently between versions will be converted to the v2 format.
    public func v2Representation() -> InstanceV2 {
        let v2Thumbnail: InstanceV2.Thumbnail?
        if let thumbnail {
            v2Thumbnail = .init(url: thumbnail)
        } else {
            v2Thumbnail = nil
        }

        // V2 configuration combines properties from v1 configuration and other v1 properties
        var v2Configuration: InstanceConfiguration?
        if let configuration {
            var config = configuration
            config.urls = .init(streaming: self.urls?.streamingApi)
            v2Configuration = config
        } else if let urls {
            v2Configuration = .init(urls: .init(streaming: self.urls?.streamingApi))
        } else {
            v2Configuration = nil
        }

        return InstanceV2(
            domain: uri,
            title: title,
            version: version,
            sourceURL: nil,
            description: shortDescription,
            usage: nil,
            thumbnail: v2Thumbnail,
            icon: nil,
            languages: languages,
            configuration: v2Configuration,
            registrations: .init(
                enabled: registrationsEnabled,
                approvalRequired: approvalRequired
            ),
            apiVersions: nil,
            contact: .init(email: email, account: contactAccount),
            rules: rules
        )
    }
}
