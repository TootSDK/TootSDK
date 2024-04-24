// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a rich preview card that is generated using OpenGraph tags from a URL.
public struct Card: Codable, Hashable {
    public init(
        url: String,
        title: String,
        description: String,
        type: Card.CardType,
        authorName: String? = nil,
        authorUrl: String? = nil,
        providerName: String? = nil,
        providerUrl: String? = nil,
        html: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        image: String? = nil,
        embedUrl: String? = nil,
        blurhash: String? = nil
    ) {
        self.url = url
        self.title = title
        self.description = description
        self.type = type
        self.authorName = authorName
        self.authorUrl = authorUrl
        self.providerName = providerName
        self.providerUrl = providerUrl
        self.html = html
        self.width = width
        self.height = height
        self.image = image
        self.embedUrl = embedUrl
        self.blurhash = blurhash
    }

    public enum CardType: String, Codable, Hashable {
        case link, photo, video, rich
    }

    /// Location of linked resource.
    public var url: String
    /// Title of linked resource.
    public var title: String
    /// Description of preview.
    public var description: String
    /// The type of preview card.
    public var type: CardType
    /// The author of the original resource.
    public var authorName: String?
    /// A link to the author of the original resource.
    public var authorUrl: String?
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
    /// For ``CardType/photo`` embeds, the URL of the image file on its original server.
    public var embedUrl: String?
    /// A hash computed by the BlurHash algorithm, for generating colorful preview thumbnails when media has not been downloaded yet.
    public var blurhash: String?
}
