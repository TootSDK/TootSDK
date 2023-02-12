//  TootClient+Search.swift
//  Created by Łukasz Rutkowski on 12/02/2023.

import Foundation

public extension TootClient {

    /// Search for content in accounts, posts and hashtags.
    /// - Parameter query: The search query.
    func search(_ params: SearchParams) async throws -> Search {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "search"])
            $0.method = .get
            $0.query = params.queryItems
        }
        return try await fetch(Search.self, req)
    }
}
