// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct FeaturedTag: Codable, Hashable {
    public var id: String
    public var name: String
    public var url: String
    public var statusesCount: Int
    public var lastStatusAt: Date

    public init(id: String, name: String, url: String, statusesCount: Int, lastStatusAt: Date) {
        self.id = id
        self.name = name
        self.url = url
        self.statusesCount = statusesCount
        self.lastStatusAt = lastStatusAt
    }
}
