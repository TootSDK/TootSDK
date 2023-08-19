//
//  TootClient+Tags.swift
//  Created by Łukasz Rutkowski on 21/04/2023.
//

import Foundation

public extension TootClient {

    /// Get a tag.
    /// - Parameter id: Name of the tag.
    func getTag(_ id: String) async throws -> Tag {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "tags", id])
            $0.method = .get
        }

        return try await fetch(Tag.self, req)
    }

    /// Follow a tag.
    ///
    /// - Parameter id: Name of the tag.
    /// - Note: Requires hashtag following feature to be available.
    @discardableResult
    func followTag(_ id: String) async throws -> Tag {
        try requireFeature(.hashtagFollowing)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "tags", id, "follow"])
            $0.method = .post
        }

        return try await fetch(Tag.self, req)
    }

    /// Unfollow a tag.
    ///
    /// - Parameter id: Name of the tag.
    /// - Note: Requires hashtag following feature to be available.
    @discardableResult
    func unfollowTag(_ id: String) async throws -> Tag {
        try requireFeature(.hashtagFollowing)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "tags", id, "unfollow"])
            $0.method = .post
        }

        return try await fetch(Tag.self, req)
    }

    /// Get all tags which the current account is following.
    /// - Parameters:
    ///     - pageInfo: PagedInfo object for max/min/since ids.
    ///     - limit: Maximum number of results to return. Defaults to 100 tags. Max 200 tags.
    /// - Returns: the tags requested
    /// - Note: Requires hashtag following feature to be available.
    func getFollowedTags(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Tag]> {
        try requireFeature(.hashtagFollowing)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "followed_tags"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
    }
}

extension TootFeature {

    /// Ability to follow hashtags.
    ///
    /// Available for Mastodon and Friendica.
    public static let hashtagFollowing = TootFeature(supportedFlavours: [.mastodon, .friendica])
}
