// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Instance: Codable, Hashable {
    public init(uri: String,
                title: String,
                description: String,
                shortDescription: String? = nil,
                email: String,
                version: String,
                languages: [String]? = nil,
                registrations: Bool? = nil,
                approvalRequired: Bool? = nil,
                invitesEnabled: Bool? = nil,
                urls: Instance.URLs,
                stats: Instance.Stats,
                thumbnail: String? = nil,
                contactAccount: Account? = nil) {
        self.domain = uri
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
        self.contactAccount = contactAccount
    }

    /// The domain name of the instance.
    public var domain: String
    /// The title of the website.
    public var title: String
    /// Admin-defined description of the Fediverse site.
    public var description: String
    /// A shorter description defined by the admin.
    public var shortDescription: String?
    /// An email that may be contacted for any inquiries.
    public var email: String
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
    public var urls: URLs
    /// Statistics about how much information the instance contains.
    public var stats: Stats
    /// Banner image for the website.
    public var thumbnail: String?
    /// A user that can be contacted, as an alternative to email.
    public var contactAccount: Account?

    public struct URLs: Codable, Hashable {
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
        
        enum CodingKeys: String, CodingKey {
            case userCount
            case postCount = "status_count"
            case domainCount
        }
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
