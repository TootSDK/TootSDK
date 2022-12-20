//
//  TootClient+TimeLine.swift
//  
//
//  Created by dave on 26/11/22.
//

import Foundation

public extension TootClient {
    
    func getHomeTimeline(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Status]> {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "home"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        let (data, response) = try await fetch(req: req)
        let decoded = try decode([Status].self, from: data)
        var pagination: Pagination?
        
        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }
        
        let info = PagedInfo(maxId: pagination?.maxId, minId: pagination?.minId, sinceId: pagination?.sinceId)
        
        return PagedResult(result: decoded, info: info)
    }
    
    /// View statuses in the given list timeline.
    func getListTimeline(listId: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Status]> {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "timelines", "list", listId])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        let (data, response) = try await fetch(req: req)
        let decoded = try decode([Status].self, from: data)
        var pagination: Pagination?
        
        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }
        
        let info = PagedInfo(maxId: pagination?.maxId, minId: pagination?.minId, sinceId: pagination?.sinceId)
        
        return PagedResult(result: decoded, info: info)
    }
    
}
