//
//  SearchAccountsParams.swift
//  Created by Łukasz Rutkowski on 03/07/2023.
//

import Foundation

public struct SearchAccountsParams: Sendable {
    /// The search query.
    public var query: String
    /// Attempt WebFinger lookup? Defaults to `false`.
    public var resolve: Bool?
    /// Only include accounts that the user is following? Defaults to `false`.
    public var following: Bool?

    /// The search parameters.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - resolve: Attempt WebFinger lookup? Defaults to `false`.
    ///   - following: Only include accounts that the user is following? Defaults to `false`.
    public init(
        query: String,
        resolve: Bool? = nil,
        following: Bool? = nil
    ) {
        self.query = query
        self.resolve = resolve
        self.following = following
    }
}

extension SearchAccountsParams {
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "resolve", value: resolve?.description),
            URLQueryItem(name: "following", value: following?.description),
        ].filter { $0.value != nil }
    }
}
