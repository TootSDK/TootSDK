// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Card: Codable, Hashable {
    public init(url: String,
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
                embedUrl: String? = nil) {
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
    }

    public enum CardType: String, Codable, Hashable {
        case link, photo, video, rich
    }

    public var url: String
    public var title: String
    public var description: String
    public var type: CardType
    public var authorName: String?
    public var authorUrl: String?
    public var providerName: String?
    public var providerUrl: String?
    public var html: String?
    public var width: Int?
    public var height: Int?
    public var image: String?
    public var embedUrl: String?
}
