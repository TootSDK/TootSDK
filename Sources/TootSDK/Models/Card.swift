// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a rich preview card that is generated using OpenGraph tags from a URL.
public struct Card: Codable, Hashable, Sendable {
    public init(
        url: String,
        title: String,
        description: String,
        language: String? = nil,
        type: Card.CardType,
        authorName: String? = nil,
        authorUrl: String? = nil,
        authors: [Author]? = nil,
        publishedAt: Date? = nil,
        providerName: String? = nil,
        providerUrl: String? = nil,
        html: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        image: String? = nil,
        imageDescription: String? = nil,
        embedUrl: String? = nil,
        blurhash: String? = nil
    ) {
        self.url = url
        self.title = title
        self.description = description
        self.language = language
        self.type = .some(type)
        self.authorName = authorName
        self.authorUrl = authorUrl
        self.authors = authors
        self.publishedAt = publishedAt
        self.providerName = providerName
        self.providerUrl = providerUrl
        self.html = html
        self.width = width
        self.height = height
        self.image = image
        self.imageDescription = imageDescription
        self.embedUrl = embedUrl
        self.blurhash = blurhash
    }

    public enum CardType: String, Codable, Hashable, Sendable {
        case link, photo, video, rich
    }

    /// Information about an author of a linked resource.
    public struct Author: Codable, Hashable, Sendable {
        /// The author's name.
        public var name: String?
        /// The author's URL.
        public var url: String?
        /// The author's Fediverse account.
        public var account: Account?

        public init(name: String? = nil, url: String? = nil, account: Account? = nil) {
            self.name = name
            self.url = url
            self.account = account
        }
    }

    /// Location of linked resource.
    public var url: String
    /// Title of linked resource.
    public var title: String
    /// Description of preview.
    public var description: String
    /// The language code of the linked resource.
    public var language: String?
    /// The type of preview card.
    public var type: OpenEnum<CardType>
    /// The author of the original resource.
    public var authorName: String?
    /// A link to the author of the original resource.
    public var authorUrl: String?
    /// A list of authors of the original resource, which may include links to their Fediverse accounts.
    public var authors: [Author]?
    /// The date the linked resource was published.
    public var publishedAt: Date?
    /// The provider of the original resource.
    public var providerName: String?
    /// A link to the provider of the original resource.
    public var providerUrl: String?
    /// HTML to be used for generating the preview card, used for ``CardType/video`` embeds.
    public var html: String?
    /// Width of preview in pixels.
    public var width: Int?
    /// Height of preview in pixels.
    public var height: Int?
    /// Preview thumbnail.
    public var image: String?
    /// Alt text of the preview thumbnail (``image``)
    public var imageDescription: String?
    /// For ``CardType/photo`` embeds, the URL of the image file on its original server.
    public var embedUrl: String?
    /// A hash computed by the BlurHash algorithm, for generating colorful preview thumbnails when media has not been downloaded yet.
    public var blurhash: String?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        self.type = try container.decode(OpenEnum<Card.CardType>.self, forKey: .type)
        self.authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        self.authorUrl = try container.decodeIfPresent(String.self, forKey: .authorUrl)
        self.authors = try container.decodeIfPresent([Card.Author].self, forKey: .authors)
        self.publishedAt = try container.decodeIfPresent(Date.self, forKey: .publishedAt)
        self.providerName = try container.decodeIfPresent(String.self, forKey: .providerName)
        self.providerUrl = try container.decodeIfPresent(String.self, forKey: .providerUrl)
        self.html = try container.decodeIfPresent(String.self, forKey: .html)
        self.width = try container.decodeIntFromStringIfPresent(forKey: .width)
        self.height = try container.decodeIntFromStringIfPresent(forKey: .height)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.imageDescription = try container.decodeIfPresent(String.self, forKey: .imageDescription)
        self.embedUrl = try container.decodeIfPresent(String.self, forKey: .embedUrl)
        self.blurhash = try container.decodeIfPresent(String.self, forKey: .blurhash)
    }
}
