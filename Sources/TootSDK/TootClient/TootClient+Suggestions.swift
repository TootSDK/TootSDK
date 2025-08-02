//
//  TootClient+Suggestions.swift
//

import Foundation

extension TootClient {

    /// Accounts that are promoted by staff, or that the user has had past positive interactions with, but is not yet following.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 40, max 80.
    /// - Returns: Array of ``Suggestion``.
    public func getSuggestions(limit: Int? = nil) async throws -> [Suggestion] {
        let response = try await getSuggestionsRaw(limit: limit)
        return response.data
    }

    /// Accounts that are promoted by staff, or that the user has had past positive interactions with, but is not yet following with HTTP response metadata
    ///
    /// - Parameters:
    ///   - limit: Maximum number of results to return. Defaults to 40, max 80.
    /// - Returns: TootResponse containing array of Suggestions and HTTP metadata
    public func getSuggestionsRaw(limit: Int? = nil) async throws -> TootResponse<[Suggestion]> {
        try requireFeature(.suggestions)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "suggestions"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit)
        }

        return try await fetchRaw([Suggestion].self, req)
    }

    /// Remove an account from follow suggestions.
    /// - Parameter id: The ID of the Account in the database.
    public func removeSuggestion(id: String) async throws {
        try requireFeature(.suggestions)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "suggestions", id])
            $0.method = .delete
        }
        _ = try await fetch(req: req)
    }

}

extension TootFeature {

    /// Ability to query and remove suggestions
    ///
    public static let suggestions = TootFeature(supportedFlavours: [.mastodon, .firefish, .sharkey, .catodon, .iceshrimp])
}
