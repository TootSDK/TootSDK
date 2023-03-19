// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct FeaturedTag: Codable, Hashable, Identifiable {

    /// ID of the featured tag in database.
    public var id: String

    /// Name of the tag being featured.
    public var name: String

    /// Link to all posts by a user that contain this tag.
    public var url: String

    /// Number of authored posts containing this tag.
    public var postsCount: Int

    /// The date of last authored post containing this tag.
    public var lastPostAt: Date

    public init(id: String, name: String, url: String, postsCount: Int, lastPostAt: Date) {
        self.id = id
        self.name = name
        self.url = url
        self.postsCount = postsCount
        self.lastPostAt = lastPostAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        // Mastodon incorrectly returns this count as string
        self.postsCount = try container.decodeIntFromString(forKey: .postsCount)
        self.lastPostAt = try container.decode(Date.self, forKey: .lastPostAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case postsCount = "statusesCount"
        case lastPostAt = "lastStatusAt"
    }
}
