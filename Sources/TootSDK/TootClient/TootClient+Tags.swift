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
    /// - Parameter id: Name of the tag.
    @discardableResult
    func followTag(_ id: String) async throws -> Tag {
        try requireFlavour(flavoursSupportingFollowingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "tags", id, "follow"])
            $0.method = .post
        }

        return try await fetch(Tag.self, req)
    }

    /// Unfollow a tag.
    /// - Parameter id: Name of the tag.
    @discardableResult
    func unfollowTag(_ id: String) async throws -> Tag {
        try requireFlavour(flavoursSupportingFollowingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "tags", id, "unfollow"])
            $0.method = .post
        }

        return try await fetch(Tag.self, req)
    }

    /// Get all tags which the current account is following.
    /// - Returns: the tags requested
    func getFollowedTags(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Tag]> {
        try requireFlavour(flavoursSupportingFollowingTags)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "followed_tags"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        
        return try await fetchPagedResult(req, pageInfo, limit: limit)
    }

    /// Tells whether current flavour supports following or unfollowing tags.
    var canFollowTags: Bool {
        flavoursSupportingFollowingTags.contains(flavour)
    }

    private var flavoursSupportingFollowingTags: Set<TootSDKFlavour> {
        [.mastodon, .friendica]
    }
}
