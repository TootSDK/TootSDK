//
//  TootClient+Suggestions.swift
//

import Foundation

public extension TootClient {
    
    /// Accounts that are promoted by staff, or that the user has had past positive interactions with, but is not yet following.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 40, max 80.
    /// - Returns: Array of ``Suggestion``.
    func getSuggestions(limit: Int? = nil) async throws -> [Suggestion] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "suggestions"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit)
        }

        return try await fetch([Suggestion].self, req)
    }

}
