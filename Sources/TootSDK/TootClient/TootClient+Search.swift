//  TootClient+Search.swift
//  Created by Łukasz Rutkowski on 12/02/2023.

import Foundation

extension TootClient {

    /// Search for content in accounts, posts and hashtags.
    ///
    /// - Parameters:
    ///   - params: The search parameters.
    ///   - pageInfo: PagedInfo object for max/min/since ids.
    ///   - limit: Maximum number of results to return. Defaults to 40.
    ///   - offset: Skip the first n results.
    /// - Returns: Search results.
    public func search(params: SearchParams, _ pageInfo: PagedInfo? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> Search {
        let response = try await searchRaw(params: params, pageInfo, limit: limit, offset: offset)
        return response.data
    }

    /// Search for content in accounts, posts and hashtags with HTTP response metadata
    ///
    /// - Parameters:
    ///   - params: The search parameters.
    ///   - pageInfo: PagedInfo object for max/min/since ids.
    ///   - limit: Maximum number of results to return. Defaults to 40.
    ///   - offset: Skip the first n results.
    /// - Returns: TootResponse containing search results and HTTP metadata
    public func searchRaw(params: SearchParams, _ pageInfo: PagedInfo? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> TootResponse<Search> {
        if params.excludeUnreviewed != nil {
            try requireFeature(.searchExcludeUnreviewed)
        }
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "search"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit, offset: offset) + params.queryItems
        }
        return try await fetchRaw(Search.self, req)
    }
}

extension TootFeature {
    /// The ability to use the `exclude_unreviewed` search parameter.
    public static let searchExcludeUnreviewed = TootFeature(supportedFlavours: [.mastodon])
}
