//
//  TrendingLink.swift
//
//
//  Created by Dale Price on 4/7/23.
//

import Foundation

public struct TrendingLink: Codable, Hashable {
    public init(
        url: String,
        title: String,
        description: String,
        authorName: String? = nil,
        authorUrl: String? = nil,
        providerName: String? = nil,
        providerUrl: String? = nil,
        html: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        image: String? = nil,
        embedUrl: String? = nil,
        blurhash: String? = nil,
        history: [History]? = nil
    ) {
        self.url = url
        self.title = title
        self.description = description
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
        self.history = history
    }

    public var url: String
    public var title: String
    public var description: String
    public var authorName: String?
    public var authorUrl: String?
    public var providerName: String?
    public var providerUrl: String?
    public var html: String?
    public var width: Int?
    public var height: Int?
    public var image: String?
    public var embedUrl: String?
    public var blurhash: String?
    public var history: [History]?
}
