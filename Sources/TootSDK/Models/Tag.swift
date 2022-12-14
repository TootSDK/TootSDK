// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a hashtag used within the content of a status.
public struct Tag: Codable, Hashable {
    public init(name: String, url: String, history: [TagHistory]? = nil) {
        self.name = name
        self.url = url
        self.history = history
    }

    /// The value of the hashtag after the # sign.
    public let name: String
    /// A link to the hashtag on the instance.
    public let url: String
    /// Usage statistics for given days.
    public let history: [TagHistory]?
}
