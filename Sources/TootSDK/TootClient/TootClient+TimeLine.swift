//
//  TootClient+TimeLine.swift
//  
//
//  Created by dave on 26/11/22.
//

import Foundation

public extension TootClient {
    
    /// Generic post request function
    /// - Parameters:
    ///   - req: the http request to make
    ///   - pageInfo: the page info to be applied
    ///   - limit: the limit of posts being requested
    /// - Returns: a paged result with an array of posts
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
    
    /// Retrieves a timeline
    /// - Parameters:
    ///   - timeline: The timeline being requested
    ///   - pageInfo: a PageInfo struct that tells the API how to page the response, typically with a minId set of the highest id you last saw
    ///   - limit: Maximum number of results to return (defaults to 20 on Mastodon with a max of 40)
    /// - Returns: a PagedResult containing the posts retrieved
    func getTimeline(_ timeline: TootTimeline, pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let urlPaths = timeline.getURLPaths()
        let timelineQuery = timeline.getQuery()
                
        let req = HTTPRequestBuilder {
            $0.url = getURL(urlPaths)
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit, query: timelineQuery)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
}
