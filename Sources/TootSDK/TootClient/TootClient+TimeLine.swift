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
    
    func getHomeTimeline(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "home"])
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
    
}
