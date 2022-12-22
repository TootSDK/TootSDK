// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct FeaturedTag: Codable, Hashable {
    public var id: String
    public var name: String
    public var url: String
    public var postsCount: Int
    public var lastPostAt: Date

    public init(id: String, name: String, url: String, postsCount: Int, lastPostAt: Date) {
        self.id = id
        self.name = name
        self.url = url
        self.postsCount = postsCount
        self.lastPostAt = lastPostAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case postsCount = "statuses_count"
        case lastPostAt = "last_status_at"
    }
}
