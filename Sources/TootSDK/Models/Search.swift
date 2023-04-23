//  Search.swift
//  Created by Łukasz Rutkowski on 12/02/2023.

import Foundation

/// Represents the results of a search.
public struct Search: Codable, Sendable {

    public init(accounts: [Account] = [], posts: [Post] = [], hashtags: [Tag] = []) {
        self.accounts = accounts
        self.posts = posts
        self.hashtags = hashtags
    }

    /// Accounts which match the given query.
    public let accounts: [Account]
    /// Posts which match the given query.
    public let posts: [Post]
    /// Hashtags which match the given query.
    public let hashtags: [Tag]
}

public extension Search {
    enum CodingKeys: String, CodingKey {
        case accounts
        case posts = "statuses"
        case hashtags
    }
}
