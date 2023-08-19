//
//  TootClient+FeaturedTags.swift
//
//
//  Created by Philip Chu on 6/9/23.
//

import Foundation

public extension TootClient {
    /// Get tags featured by user.
    ///
    /// - Parameter userID: ID of user in database.
    /// - Returns: The featured tags or an error if unable to retrieve.
    func getFeaturedTags(forUser userID: String) async throws -> [FeaturedTag] {
        try requireFlavour(flavoursSupportingFeaturingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", userID, "featured_tags"])
            $0.method = .get
        }
        return try await fetch([FeaturedTag].self, req)
    }

    /// List all hashtags featured on your profile.
    ///
    /// - Returns: The featured tags or an error if unable to retrieve.
    func getFeaturedTags() async throws -> [FeaturedTag] {
        try requireFlavour(flavoursSupportingFeaturingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags"])
            $0.method = .get
        }
        return try await fetch([FeaturedTag].self, req)
    }

    /// Shows up to 10 recently-used tags.
    ///
    /// - Returns: Array of ``Tag``.
    func getFeaturedTagsSuggestions() async throws -> [Tag] {
        try requireFlavour(flavoursSupportingFeaturingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags", "suggestions"])
            $0.method = .get
        }

        return try await fetch([Tag].self, req)
    }

    /// Promote a hashtag on your profile.
    /// - Parameter name: The hashtag to be featured, without the hash sign.
    @discardableResult
    func featureTag(name: String) async throws -> FeaturedTag {
        try requireFlavour(flavoursSupportingFeaturingTags)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags"])
            $0.method = .post
            $0.body = try .json(FeatureTagParams(name: name),
                                encoder: self.encoder)
        }

        return try await fetch(FeaturedTag.self, req)
    }

    /// Stop promoting a hashtag on your profile.
    /// - Parameter id: The ID of the FeaturedTag in the database.
    func unfeatureTag(id: String) async throws {
        try requireFlavour(flavoursSupportingFeaturingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "featured_tags", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

    /// Tells whether current flavour supports featuring tags.
    var canFeatureTags: Bool {
        flavoursSupportingFeaturingTags.contains(flavour)
    }

    private var flavoursSupportingFeaturingTags: Set<TootSDKFlavour> {
        [.mastodon]
    }
}
