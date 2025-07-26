//
//  TootClient+Trends.swift
//
//
//  Created by Dale Price on 4/7/23.
//

import Foundation

extension TootClient {

    /// Get trending tags
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 10, max 20.
    ///   - offset: Skip the first n results.
    /// - Returns: Array of ``Tag``.
    public func getTrendingTags(limit: Int? = nil, offset: Int? = nil) async throws -> [Tag] {
        let response = try await getTrendingTagsRaw(limit: limit, offset: offset)
        return response.data
    }

    /// Get trending tags with HTTP response metadata
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 10, max 20.
    ///   - offset: Skip the first n results.
    /// - Returns: TootResponse containing array of Tags and HTTP metadata
    public func getTrendingTagsRaw(limit: Int? = nil, offset: Int? = nil) async throws -> TootResponse<[Tag]> {
        try requireFeature(.trendingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "trends", "tags"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset)
        }

        return try await fetchRaw([Tag].self, req)
    }

    /// Get trending posts
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 20, max 40.
    ///   - offset: Skip the first n results.
    /// - Returns: Array of ``Post``.
    public func getTrendingPosts(limit: Int? = nil, offset: Int? = nil) async throws -> [Post] {
        let response = try await getTrendingPostsRaw(limit: limit, offset: offset)
        return response.data
    }

    /// Get trending posts with HTTP response metadata
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 20, max 40.
    ///   - offset: Skip the first n results.
    /// - Returns: TootResponse containing array of Posts and HTTP metadata
    public func getTrendingPostsRaw(limit: Int? = nil, offset: Int? = nil) async throws -> TootResponse<[Post]> {
        try requireFeature(.trendingPosts)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "trends", "statuses"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset)
        }

        return try await fetchRaw([Post].self, req)
    }

    /// Get trending links
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 10, max 20.
    ///   - offset: Skip the first n results.
    /// - Returns: Array of ``TrendingLink``.
    public func getTrendingLinks(limit: Int? = nil, offset: Int? = nil) async throws -> [TrendingLink] {
        let response = try await getTrendingLinksRaw(limit: limit, offset: offset)
        return response.data
    }

    /// Get trending links with HTTP response metadata
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 10, max 20.
    ///   - offset: Skip the first n results.
    /// - Returns: TootResponse containing array of TrendingLinks and HTTP metadata
    public func getTrendingLinksRaw(limit: Int? = nil, offset: Int? = nil) async throws -> TootResponse<[TrendingLink]> {
        try requireFeature(.trendingLinks)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "trends", "links"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset)
        }

        return try await fetchRaw([TrendingLink].self, req)
    }
}

extension TootFeature {

    @available(*, deprecated)
    /// Ability to query trends
    ///
    public static let trends = TootFeature(supportedFlavours: [.mastodon, .firefish, .catodon, .iceshrimp])
}

extension TootFeature {

    /// Ability to query trending posts
    ///
    public static let trendingPosts = TootFeature(supportedFlavours: [.mastodon, .firefish, .catodon, .iceshrimp])
}

extension TootFeature {

    /// Ability to query trending tags
    ///
    public static let trendingTags = TootFeature(supportedFlavours: [.mastodon, .sharkey])
}

extension TootFeature {

    /// Ability to query trending links
    ///
    public static let trendingLinks = TootFeature(supportedFlavours: [.mastodon])
}
