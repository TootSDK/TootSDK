//  TootClient+Search.swift
//  Created by Łukasz Rutkowski on 12/02/2023.

import Foundation

public extension TootClient {

    /// Search for content in accounts, posts and hashtags.
    ///
    /// - Parameters:
    ///   - params: The search parameters.
    ///   - pageInfo: PagedInfo object for max/min/since ids.
    ///   - limit: Maximum number of results to return. Defaults to 40.
    ///   - offset: Skip the first n results.
    /// - Returns: Search results.
    func search(params: SearchParams, _ pageInfo: PagedInfo? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> Search {
        if params.excludeUnreviewed != nil && flavour != .mastodon {
            try requireFlavour([.mastodon])
        }
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "search"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit, offset: offset) + params.queryItems
        }
        return try await fetch(Search.self, req)
    }
}
