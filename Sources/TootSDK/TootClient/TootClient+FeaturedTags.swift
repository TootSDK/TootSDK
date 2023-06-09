//
//  TootClient+FeaturedTags.swift
//  
//
//  Created by Philip Chu on 6/9/23.
//

import Foundation

extension TootClient {
    /// Get tags featured by user.
    ///
    /// - Parameter userID: ID of user in database.
    /// - Returns: The featured tags or an error if unable to retrieve.
    public func getFeaturedTags(forUser userID: String) async throws -> [FeaturedTag] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", userID, "featured_tags"])
            $0.method = .get
        }
        return try await fetch([FeaturedTag].self, req)
    }

    /// Shows up to 10 recently-used tags.
    ///
    /// - Returns: Array of ``Tag``.
    func getFeaturedTagsSuggestions() async throws -> [Tag] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags", "suggestions"])
            $0.method = .get
        }

        return try await fetch([Tag].self, req)
    }
}
