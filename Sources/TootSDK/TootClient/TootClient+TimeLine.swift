//
//  TootClient+TimeLine.swift
//  
//
//  Created by dave on 26/11/22.
//

import Foundation

public extension TootClient {
    
    internal func getPosts(_ req: HTTPRequestBuilder, _ pageInfo: PagedInfo? = nil, _ limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let (data, response) = try await fetch(req: req)
        let decoded = try decode([Post].self, from: data)
        var pagination: Pagination?
        
        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }
        
        let info = PagedInfo(maxId: pagination?.maxId, minId: pagination?.minId, sinceId: pagination?.sinceId)
        
        return PagedResult(result: decoded, info: info)
    }
    
    /// Retrieves the user's home timeline
    /// - Parameters:
    ///   - pageInfo: a PageInfo struct that tells the API how to page the response, typically with a minId set of the highest id you last saw
    ///   - limit: Maximum number of results to return (defaults to 20 on Mastodon with a max of 40)
    /// - Returns: a PagedResult containing the posts retrieved
    func getHomeTimeline(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "home"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
    /// Retrieves the user's local timeline
    /// - Parameters:
    ///   - pageInfo: a PageInfo struct that tells the API how to page the response, typically with a minId set of the highest id you last saw
    ///   - limit: Maximum number of results to return (defaults to 20 on Mastodon with a max of 40)
    ///   - onlyMedia: Return only statuses with media attachments
    /// - Returns: a PagedResult containing the posts retrieved
    func getLocalTimeline(_ pageInfo: PagedInfo? = nil, limit: Int? = nil, onlyMedia: Bool? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "public"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit, onlyMedia: onlyMedia, locality: .local)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
    /// Retrieves the user's federated timeline
    /// - Parameters:
    ///   - pageInfo: a PageInfo struct that tells the API how to page the response, typically with a minId set of the highest id you last saw
    ///   - limit: Maximum number of results to return (defaults to 20 on Mastodon with a max of 40)
    ///   - onlyMedia: Return only statuses with media attachments
    /// - Returns: a PagedResult containing the posts retrieved
    func getFederatedTimeline(_ pageInfo: PagedInfo? = nil, limit: Int? = nil, onlyMedia: Bool? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "public"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit, onlyMedia: onlyMedia)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
    /// Retrieves public statuses containing the given hashtag
    /// - Parameters:
    ///   - tag: The name of the hashtag, not including the `#` symbol
    ///   - anyTags: Return statuses that contain any of these additional tags
    ///   - allTags: Return statuses that contain all of these additional tags
    ///   - noneTags: Return statuses that contain none of these additional tags
    ///   - pageInfo: a PageInfo struct that tells the API how to page the response, typically with a minId set of the highest id you last saw
    ///   - limit: Maximum number of results to return (defaults to 20 on Mastodon with a max of 40)
    ///   - onlyMedia: Return only statuses with media attachments
    ///   - locality: Whether to return only local or only remote statuses (optional, returns both if not specified)
    /// - Returns: a PagedResult containing the posts retrieved
    func getHashtagTimeline(tag: String, anyTags: [String]? = nil, allTags: [String]? = nil, noneTags: [String]? = nil, _ pageInfo: PagedInfo? = nil, limit: Int? = nil, onlyMedia: Bool? = nil, locality: TimelineLocality? = nil) async throws -> PagedResult<[Post]> {
        var query = getQueryParams(pageInfo, limit: limit, onlyMedia: onlyMedia, locality: locality)
        if let anyTags = anyTags {
            for tag in anyTags {
                query.append(.init(name: "any[]", value: tag))
            }
        }
        if let allTags = allTags {
            for tag in allTags {
                query.append(.init(name: "all[]", value: tag))
            }
        }
        if let noneTags = noneTags {
            for tag in noneTags {
                query.append(.init(name: "none[]", value: tag))
            }
        }
        
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "tag", tag])
            $0.method = .get
            $0.query = query
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
    /// View posts in the given list timeline.
    func getListTimeline(listId: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "list", listId])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
    /// View posts that the user has favourited.
    func getFavorites(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "favourites"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
    /// View posts that the user has bookmarked.
    func getBookmarks(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "bookmarks"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
}
