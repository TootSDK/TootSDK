// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents the results of a search.
public struct Results: Codable {
    public init(accounts: [Account], posts: [Post], hashtags: [Tag]) {
        self.accounts = accounts
        self.posts = posts
        self.hashtags = hashtags
    }

    /// Accounts which match the given query
    public var accounts: [Account]
    /// Posts which match the given query
    public var posts: [Post]
    /// Hashtags which match the given query
    public var hashtags: [Tag]
    
    enum CodingKeys: String, CodingKey {
        case accounts
        case posts = "statuses"
        case hashtags
    }
}
