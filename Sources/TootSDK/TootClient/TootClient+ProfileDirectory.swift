//
//  TootClient+Directory.swift
//  
//
//  Created by Philip Chu on 5/29/23.
//

import Foundation

public extension TootClient {
    
    /// List accounts visible in the directory.
    ///
    /// - Parameters:
    ///   - offset. Skip the first n results.
    ///   - limit: How many accounts to load. Defaults to 40 accounts. Max 80 accounts.
    ///   - order. Use active to sort by most recently posted statuses (default) or new to sort by most recently created profiles.
    ///   - local. If true, returns only local accounts.
    /// - Returns: Array of ``Account``.
    func getProfileDirectory(offset: Int? = nil, limit: Int? = nil, params: ProfileDirectoryParams? = nil) async throws -> [Account] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "directory"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset)
        }
        
        return try await fetch([Account].self, req)
    }
}
