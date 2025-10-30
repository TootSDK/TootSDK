//
//  TrendingLink.swift
//
//
//  Created by Dale Price on 4/7/23.
//

import Foundation

public struct TrendingLink: Codable, Hashable, Sendable {
    public init(
        url: String,
        title: String,
        description: String,
        language: String? = nil,
        type: Card.CardType,
        authorName: String? = nil,
        authorUrl: String? = nil,
        authors: [Card.Author]? = nil,
        publishedAt: Date? = nil,
        providerName: String? = nil,
        providerUrl: String? = nil,
        html: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        image: String? = nil,
        imageDescription: String? = nil,
        embedUrl: String? = nil,
        blurhash: String? = nil,
        history: [History]? = nil
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
        self.history = history
    }

    public var url: String
    public var title: String
    public var description: String
    /// The language code of the link.
    public var language: String?
    /// The type of preview card.
    public var type: OpenEnum<Card.CardType>
    public var authorName: String?
    public var authorUrl: String?
    /// A list of authors of the original resource, which may include links to their Fediverse accounts.
    public var authors: [Card.Author]?
    /// The date the linked resource was published.
    public var publishedAt: Date?
    public var providerName: String?
    public var providerUrl: String?
    public var html: String?
    public var width: Int?
    public var height: Int?
    public var image: String?
    /// Alt text of the preview thumbnail (``image``)
    public var imageDescription: String?
    public var embedUrl: String?
    public var blurhash: String?
    public var history: [History]?
}
