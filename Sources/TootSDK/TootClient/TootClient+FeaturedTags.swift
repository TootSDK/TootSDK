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
    /// - Note: Requires featured tags feature to be available.
    public func getFeaturedTags(forUser userID: String) async throws -> [FeaturedTag] {
        let response = try await getFeaturedTagsRaw(forUser: userID)
        return response.data
    }

    /// Get tags featured by user with HTTP response metadata
    ///
    /// - Parameter userID: ID of user in database.
    /// - Returns: TootResponse containing the featured tags and HTTP metadata
    /// - Note: Requires featured tags feature to be available.
    public func getFeaturedTagsRaw(forUser userID: String) async throws -> TootResponse<[FeaturedTag]> {
        try requireFeature(.featuredTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", userID, "featured_tags"])
            $0.method = .get
        }
        return try await fetchRaw([FeaturedTag].self, req)
    }

    /// List all hashtags featured on your profile.
    ///
    /// - Returns: The featured tags or an error if unable to retrieve.
    /// - Note: Requires featured tags feature to be available.
    public func getFeaturedTags() async throws -> [FeaturedTag] {
        let response = try await getFeaturedTagsRaw()
        return response.data
    }

    /// List all hashtags featured on your profile with HTTP response metadata
    ///
    /// - Returns: TootResponse containing the featured tags and HTTP metadata
    /// - Note: Requires featured tags feature to be available.
    public func getFeaturedTagsRaw() async throws -> TootResponse<[FeaturedTag]> {
        try requireFeature(.featuredTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags"])
            $0.method = .get
        }
        return try await fetchRaw([FeaturedTag].self, req)
    }

    /// Shows up to 10 recently-used tags.
    ///
    /// - Returns: Array of ``Tag``.
    /// - Note: Requires featured tags feature to be available.
    public func getFeaturedTagsSuggestions() async throws -> [Tag] {
        let response = try await getFeaturedTagsSuggestionsRaw()
        return response.data
    }

    /// Shows up to 10 recently-used tags with HTTP response metadata
    ///
    /// - Returns: TootResponse containing array of Tags and HTTP metadata
    /// - Note: Requires featured tags feature to be available.
    public func getFeaturedTagsSuggestionsRaw() async throws -> TootResponse<[Tag]> {
        try requireFeature(.featuredTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags", "suggestions"])
            $0.method = .get
        }

        return try await fetchRaw([Tag].self, req)
    }

    /// Promote a hashtag on your profile.
    /// - Parameter name: The hashtag to be featured, without the hash sign.
    /// - Note: Requires featured tags feature to be available.
    @discardableResult
    public func featureTag(name: String) async throws -> FeaturedTag {
        let response = try await featureTagRaw(name: name)
        return response.data
    }

    /// Promote a hashtag on your profile with HTTP response metadata
    /// - Parameter name: The hashtag to be featured, without the hash sign.
    /// - Returns: TootResponse containing the featured tag and HTTP metadata
    /// - Note: Requires featured tags feature to be available.
    @discardableResult
    public func featureTagRaw(name: String) async throws -> TootResponse<FeaturedTag> {
        try requireFeature(.featuredTags)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags"])
            $0.method = .post
            $0.body = try .json(
                FeatureTagParams(name: name),
                encoder: self.encoder)
        }

        return try await fetchRaw(FeaturedTag.self, req)
    }

    /// Stop promoting a hashtag on your profile.
    /// - Parameter id: The ID of the FeaturedTag in the database.
    /// - Note: Requires featured tags feature to be available.
    public func unfeatureTag(id: String) async throws {
        try requireFeature(.featuredTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }
}

extension TootFeature {

    /// Ability to promote hashtags on user profiles.
    ///
    public static let featuredTags = TootFeature(supportedFlavours: [.mastodon])
}
