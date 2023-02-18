//  Search.swift
//  Created by Łukasz Rutkowski on 12/02/2023.

import Foundation

/// The search parameters.
public struct SearchParams: Sendable {
    /// The search query.
    public var query: String
    /// Specify whether to search for only specific type.
    public var type: SearchType?
    /// Attempt WebFinger lookup? Defaults to `false`.
    public var resolve: Bool?
    /// Only include accounts that the user is following? Defaults to `false`.
    public var following: Bool?
    /// If provided, will only return posts authored by this account.
    public var accountId: Account.ID?
    /// Filter out unreviewed tags? Defaults to `false`. Use `true` when trying to find trending tags.
    public var excludeUnreviewed: Bool?

    /// The search parameters.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - type: Specify whether to search for only specific type.
    ///   - resolve: Attempt WebFinger lookup? Defaults to `false`.
    ///   - following: Only include accounts that the user is following? Defaults to `false`.
    ///   - accountId: If provided, will only return posts authored by this account.
    ///   - excludeUnreviewed: Filter out unreviewed tags? Defaults to `false`. Use `true` when trying to find trending tags.
    public init(
        query: String,
        type: SearchType? = nil,
        resolve: Bool? = nil,
        following: Bool? = nil,
        accountId: Account.ID? = nil,
        excludeUnreviewed: Bool? = nil
    ) {
        self.query = query
        self.type = type
        self.resolve = resolve
        self.following = following
        self.accountId = accountId
        self.excludeUnreviewed = excludeUnreviewed
    }

    public enum SearchType: String, Sendable {
        case accounts
        case hashtags
        case posts = "statuses"
    }
}

extension SearchParams {
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: type?.rawValue),
            URLQueryItem(name: "resolve", value: resolve?.description),
            URLQueryItem(name: "following", value: following?.description),
            URLQueryItem(name: "account_id", value: accountId?.description),
            URLQueryItem(name: "exclude_unreviewed", value: excludeUnreviewed?.description)
        ].filter { $0.value != nil }
    }
}
