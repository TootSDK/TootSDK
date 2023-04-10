//
//  TootClient+Trends.swift
//  
//
//  Created by Dale Price on 4/7/23.
//

import Foundation

public extension TootClient {
    
    /// Get trending tags
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 10, max 20.
    ///   - offset: Skip the first n results.
    /// - Returns: Array of ``Tag``.
    func getTrendingTags(limit: Int? = nil, offset: Int? = nil) async throws -> [Tag] {
        let req = HTTPRequestBuilder {
            if flavour == .mastodon || flavour == .pixelfed {
                $0.url = getURL(["api", "v1", "trends", "tags"])
            } else {
                $0.url = getURL(["api", "v1", "trends"])
            }
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset)
        }
        
        return try await fetch([Tag].self, req)
    }
    
    /// Get trending posts
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 20, max 40.
    ///   - offset: Skip the first n results.
    /// - Returns: Array of ``Post``.
    func getTrendingPosts(limit: Int? = nil, offset: Int? = nil) async throws -> [Post] {
        try requireFlavour([.mastodon, .pixelfed])
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "trends", "statuses"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset)
        }
        
        return try await fetch([Post].self, req)
    }
    
    /// Get trending links
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 10, max 20.
    ///   - offset: Skip the first n results.
    /// - Returns: Array of ``TrendingLink``.
    func getTrendingLinks(limit: Int? = nil, offset: Int? = nil) async throws -> [TrendingLink] {
        try requireFlavour([.mastodon, .pixelfed])
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "trends", "links"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset)
        }
        
        return try await fetch([TrendingLink].self, req)
    }
}

