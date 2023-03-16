//
//  TootClient+TimeLine.swift
//  
//
//  Created by dave on 26/11/22.
//

import Foundation

extension TootClient {
    
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
    
    /// Provides the url paths as an array of strings, based on the type of timeline
    /// - Returns: the url paths creatd
    internal func getURLPaths(timeline: Timeline) -> [String] {
        switch timeline {
        case .home:
            return ["api", "v1", "timelines", "home"]
        case .local:
            return ["api", "v1", "timelines", "public"]
        case .federated:
            return ["api", "v1", "timelines", "public"]
        case .favourites:
            return ["api", "v1", "favourites"]
        case .bookmarks:
            return ["api", "v1", "bookmarks"]
        case .hashtag(let hashtagTimelineQuery):
            return ["api", "v1", "timelines", "tag", hashtagTimelineQuery.tag]
        case .list(let listID):
            return ["api", "v1", "timelines", "list", listID]
        case .user(let query):
            return ["api", "v1", "accounts", query.userId, "statuses"]
        }
    }
    
    /// Provides the a timeline query to be used by the get request
    /// - Returns: the timeline query created
    internal func getQuery(timeline: Timeline) -> (any TimelineQuery)? {
        switch timeline {
        case .local(let localTimelineQuery):
            return localTimelineQuery
        case .federated(let federatedTimelineQuery):
            return federatedTimelineQuery
        case .hashtag(let hashtagTimelineQuery):
            return hashtagTimelineQuery
        case .home, .favourites, .bookmarks, .list:
            return nil
        case .user(let query):
            return query
        }
    }
    
    /// Retrieves a timeline
    /// - Parameters:
    ///   - timeline: The timeline being requested
    ///   - pageInfo: a PageInfo struct that tells the API how to page the response, typically with a minId set of the highest id you last saw
    ///   - limit: Maximum number of results to return (defaults to 20 on Mastodon with a max of 40)
    /// - Returns: a PagedResult containing the posts retrieved
    public func getTimeline(_ timeline: Timeline, pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Post]> {
        let urlPaths = getURLPaths(timeline: timeline)
        let timelineQuery = getQuery(timeline: timeline)
                
        let req = HTTPRequestBuilder {
            $0.url = getURL(urlPaths)
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit, query: timelineQuery)
        }
        return try await getPosts(req, pageInfo, limit)
    }
    
}
