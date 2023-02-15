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
    /// - Returns: a PagedResult containing the posts retrieved
    func getLocalTimeline(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "public"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit) + [URLQueryItem(name: "local", value: "true")]
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
    /// Retrieves the user's federated timeline
    /// - Parameters:
    ///   - pageInfo: a PageInfo struct that tells the API how to page the response, typically with a minId set of the highest id you last saw
    ///   - limit: Maximum number of results to return (defaults to 20 on Mastodon with a max of 40)
    /// - Returns: a PagedResult containing the posts retrieved
    func getFederatedTimeline(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "public"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
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
