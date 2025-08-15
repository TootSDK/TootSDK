//
//  InstanceV2.swift
//  TootSDK
//
//  Created by Dale Price on 10/18/24.
//

import Foundation

public struct InstanceV2: Codable, Hashable, Sendable {
    /// The domain name of the instance.
    public var domain: String?
    /// The title of the website.
    public var title: String?
    public var version: String
    public var sourceURL: String?
    public var description: String?
    /// Usage data for this instance.
    public var usage: Usage?
    /// An image used to represent this instance.
    public var thumbnail: Thumbnail?
    /// The list of available size variants for this instance's configured icon.
    public var icon: [Icon]?
    /// Primary languages of the website and its staff as ISO 639-1 two-letter codes.
    public var languages: [String]?
    public var configuration: InstanceConfiguration?
    /// Information about registering for this website.
    public var registrations: Registrations
    /// Information about which version of the API is implemented by this server.
    public var apiVersions: APIVersions?
    /// Hints related to contacting a representative of the website.
    public var contact: ContactInfo?
    /// An itemized list of rules for this instance.
    public var rules: [InstanceRule]?

    public init(
        domain: String? = nil,
        title: String? = nil,
        version: String,
        sourceURL: String? = nil,
        description: String? = nil,
        usage: Usage? = nil,
        thumbnail: Thumbnail? = nil,
        icon: [Icon]? = nil,
        languages: [String]? = nil,
        configuration: InstanceConfiguration? = nil,
        registrations: Registrations,
        apiVersions: APIVersions? = nil,
        contact: ContactInfo? = nil,
        rules: [InstanceRule]? = nil
    ) {
        self.domain = domain
        self.title = title
        self.version = version
        self.sourceURL = sourceURL
        self.description = description
        self.usage = usage
        self.thumbnail = thumbnail
        self.icon = icon
        self.languages = languages
        self.configuration = configuration
        self.registrations = registrations
        self.apiVersions = apiVersions
        self.contact = contact
        self.rules = rules
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.domain = try container.decodeIfPresent(String.self, forKey: .domain)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.version = try container.decode(String.self, forKey: .version)
        self.sourceURL = try container.decodeIfPresent(String.self, forKey: .sourceURL)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.usage = try container.decodeIfPresent(InstanceV2.Usage.self, forKey: .usage)
        do {
            self.thumbnail = try container.decodeIfPresent(InstanceV2.Thumbnail.self, forKey: .thumbnail)
        } catch {
            #if canImport(OSLog)
                TootDecoder.logger.debug("Setting thumbnail to nil due to decoding error: \(error)")
            #endif
            self.thumbnail = nil
        }
        self.icon = try container.decodeIfPresent([InstanceV2.Icon].self, forKey: .icon)
        self.languages = try container.decodeIfPresent([String].self, forKey: .languages)
        self.configuration = try container.decodeIfPresent(InstanceConfiguration.self, forKey: .configuration)
        self.registrations = try container.decode(InstanceV2.Registrations.self, forKey: .registrations)
        self.apiVersions = try container.decodeIfPresent(InstanceV2.APIVersions.self, forKey: .apiVersions)
        self.contact = try container.decodeIfPresent(InstanceV2.ContactInfo.self, forKey: .contact)
        self.rules = try container.decodeIfPresent([InstanceRule].self, forKey: .rules)
    }

    enum CodingKeys: String, CodingKey {
        case domain
        case title
        case version
        case sourceURL = "sourceUrl"
        case description
        case usage
        case thumbnail
        case icon
        case languages
        case configuration
        case registrations
        case apiVersions
        case contact
        case rules
    }

    /// Usage data of an instance.
    public struct Usage: Codable, Hashable, Sendable {
        /// Data related to users on an instance.
        public struct Users: Codable, Hashable, Sendable {
            /// The number of active users on this instance in the past four weeks.
            public var activeMonth: Int

            public init(activeMonth: Int) {
                self.activeMonth = activeMonth
            }
        }

        public init(users: Users) {
            self.users = users
        }

        /// Data related to users on this instance.
        public var users: Users
    }

    /// An image used to represent an instance.
    public struct Thumbnail: Codable, Hashable, Sendable {
        /// Scaled resolution versions of the image.
        public struct Versions: Codable, Hashable, Sendable {
            /// URL for the thumbnail at 1x resolution.
            public var at1x: String?
            /// URL for the thumbnail at 2x resolution.
            public var at2x: String?

            public init(at1x: String? = nil, at2x: String? = nil) {
                self.at1x = at1x
                self.at2x = at2x
            }

            enum CodingKeys: String, CodingKey {
                case at1x = "@1x"
                case at2x = "@2x"
            }
        }

        public init(url: String, blurhash: String? = nil, versions: Versions? = nil) {
            self.url = url
            self.blurhash = blurhash
            self.versions = versions
        }

        /// URL for the thumbnail image.
        public var url: String
        /// Hash computed by the BlurHash algorithm for colorful preview thumbnails when media has not been downloaded yet.
        public var blurhash: String?
        /// Scaled resolution versions of the image intended for various DPI screens.
        public var versions: Versions?
    }

    public struct Icon: Codable, Hashable, Sendable {
        /// The URL of this version of the icon.
        public var src: String
        /// The size of this version of the icon.
        ///
        /// In the form of `12x34`, where `12` is the width and `34` is the height of the icon.
        public var size: String

        public init(src: String, size: String) {
            self.src = src
            self.size = size
        }
    }

    public struct Registrations: Codable, Hashable, Sendable {
        /// Whether registrations are enabled.
        public var enabled: Bool?
        /// Whether registrations require moderator approval.
        public var approvalRequired: Bool?
        /// An optional custom message to be shown when registrations are closed.
        public var message: String?
        /// A minimum age required to register, if configured.
        public var minAge: Int?
        /// Whether registrations require the user to provide a reason for joining. Only applicable when ``approvalRequired`` is `true`.
        public var reasonRequired: Bool?

        public init(enabled: Bool? = nil, approvalRequired: Bool? = nil, message: String? = nil, minAge: Int? = nil, reasonRequired: Bool? = nil) {
            self.enabled = enabled
            self.approvalRequired = approvalRequired
            self.message = message
            self.minAge = minAge
            self.reasonRequired = reasonRequired
        }
    }

    public struct APIVersions: Codable, Hashable, Sendable, CustomStringConvertible {
        /// Mastodon API version number that this server implements.
        ///
        /// Starting from Mastodon v4.3.0, API changes will come with a version number, which clients can check against this value.
        public var mastodon: Int?

        public init(mastodon: Int? = nil) {
            self.mastodon = mastodon
        }

        public var description: String {
            var versions: [String] = []
            if let mastodon = mastodon {
                versions.append("Mastodon API: \(mastodon)")
            }
            return versions.isEmpty ? "No API versions" : versions.joined(separator: ", ")
        }
    }

    public struct ContactInfo: Codable, Hashable, Sendable {
        /// An email address that can be messaged regarding inquiries or issues.
        public var email: String?
        /// An optional account that can be contacted natively over the network regarding inquiries or issues.
        public var account: Account?

        public init(email: String? = nil, account: Account? = nil) {
            self.email = email
            self.account = account
        }
    }
}

extension InstanceV2: Instance {
    public var thumbnailURL: String? { thumbnail?.url }
    public var streamingURL: String? { configuration?.urls?.streaming }
    public var registrationsEnabled: Bool? { registrations.enabled }
    public var approvalRequired: Bool? { registrations.approvalRequired }
    public var email: String? { contact?.email }
    public var contactAccount: Account? { contact?.account }

    public func v2Representation() -> InstanceV2 { self }
}

extension TootFeature {
    /// The ability to query the V2 Instance API.
    public static let instanceV2 = TootFeature(supportedFlavours: [
        .mastodon,
        .pixelfed,
        .pleroma,
        .friendica,
        .goToSocial,
        .firefish,
    ])
}
