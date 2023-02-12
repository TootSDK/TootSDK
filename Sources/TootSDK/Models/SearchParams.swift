//  Search.swift
//  Created by Łukasz Rutkowski on 12/02/2023.

import Foundation

/// The search parameters.
public struct SearchParams {
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
    /// Return results older than this ID.
    public var maxId: Post.ID?
    /// Return results immediately newer than this ID.
    public var minId: Post.ID?
    /// Maximum number of results to return, per type. Defaults to 20 results per category. Max 40 results per category.
    public var limit: Int?
    /// Skip the first n results.
    public var offset: Int?

    /// The search parameters.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - type: Specify whether to search for only specific type.
    ///   - resolve: Attempt WebFinger lookup? Defaults to `false`.
    ///   - following: Only include accounts that the user is following? Defaults to `false`.
    ///   - accountId: If provided, will only return posts authored by this account.
    ///   - excludeUnreviewed: Filter out unreviewed tags? Defaults to `false`. Use `true` when trying to find trending tags.
    ///   - maxId: Return results older than this ID.
    ///   - minId: Return results immediately newer than this ID.
    ///   - limit: Maximum number of results to return, per type. Defaults to 20 results per category. Max 40 results per category.
    ///   - offset: Skip the first n results.
    public init(
        query: String,
        type: SearchType? = nil,
        resolve: Bool? = nil,
        following: Bool? = nil,
        accountId: Account.ID? = nil,
        excludeUnreviewed: Bool? = nil,
        maxId: Post.ID? = nil,
        minId: Post.ID? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        self.query = query
        self.type = type
        self.resolve = resolve
        self.following = following
        self.accountId = accountId
        self.excludeUnreviewed = excludeUnreviewed
        self.maxId = maxId
        self.minId = minId
        self.limit = limit
        self.offset = offset
    }

    public enum SearchType: String {
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
            URLQueryItem(name: "exclude_unreviewed", value: excludeUnreviewed?.description),
            URLQueryItem(name: "max_id", value: maxId),
            URLQueryItem(name: "min_id", value: minId),
            URLQueryItem(name: "limit", value: limit?.description),
            URLQueryItem(name: "offset", value: offset?.description)
        ].filter { $0.value != nil }
    }
}
