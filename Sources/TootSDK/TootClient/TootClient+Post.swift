//
//  TootClient+Post.swift
//
//
//  Created by dave on 25/11/22.
//

import Foundation

extension TootClient {

    /// Publishes the post based on the components provided
    /// - Parameter PostParams:post components to be published
    /// - Returns: the published post, if successful, throws an error if not
    public func publishPost(_ params: PostParams) async throws -> Post {
        let response = try await publishPostRaw(params)
        return response.data
    }

    /// Publishes the post based on the components provided with HTTP response metadata
    /// - Parameter PostParams:post components to be published
    /// - Returns: TootResponse containing the published post and HTTP metadata
    public func publishPostRaw(_ params: PostParams) async throws -> TootResponse<Post> {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses"])
            $0.method = .post
            if flavour == .sharkey {
                $0.body = try .json(params, encoder: encoder)
            } else {
                $0.body = try .multipart(params, boundary: UUID().uuidString)
            }
        }
        return try await fetchRaw(Post.self, req)
    }

    /// Edit a given post to change its text, sensitivity, media attachments, or poll. Note that editing a poll's options will reset the votes.
    ///
    /// - Note: For Pixelfed this will first attempt to update media descriptions and then update rest of post details.
    /// If an error is thrown it is possible for some of the media descriptions to be already successfully updated.
    ///
    /// - Parameter id: The ID of the post to be changed.
    /// - Parameter params: The updated content of the post to be posted.
    /// - Returns: The post after the update.
    public func editPost(id: String, _ params: EditPostParams) async throws -> Post {
        let response = try await editPostRaw(id: id, params)
        return response.data
    }

    /// Edit a given post to change its text, sensitivity, media attachments, or poll with HTTP response metadata
    ///
    /// - Note: For Pixelfed this will first attempt to update media descriptions and then update rest of post details.
    /// If an error is thrown it is possible for some of the media descriptions to be already successfully updated.
    ///
    /// - Parameter id: The ID of the post to be changed.
    /// - Parameter params: The updated content of the post to be posted.
    /// - Returns: TootResponse containing the post after the update and HTTP metadata
    public func editPostRaw(id: String, _ params: EditPostParams) async throws -> TootResponse<Post> {
        let updateMediaSeparately = [.pixelfed, .pleroma, .akkoma, .firefish, .catodon, .iceshrimp, .sharkey].contains(flavour)
        if updateMediaSeparately {
            try await updateMediaAttributes(params.mediaAttributes ?? [])
        }

        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .put
            var params = params
            if updateMediaSeparately {
                params.mediaAttributes = nil
            }
            $0.body = try .json(params)
        }
        if flavour == .pixelfed {
            _ = try await fetch(req: req)
            // Pixelfed doesn't return edited post, simulate behavior of Mastodon by manually getting post
            return try await getPostRaw(id: id)
        }
        return try await fetchRaw(Post.self, req)
    }

    private func updateMediaAttributes(_ mediaAttributes: [EditPostParams.MediaAttribute]) async throws {
        guard !mediaAttributes.isEmpty else { return }
        try await withThrowingTaskGroup(of: Void.self) { group in
            for mediaAttribute in mediaAttributes {
                group.addTask {
                    try await self.updateMedia(
                        id: mediaAttribute.id,
                        .init(
                            description: mediaAttribute.description,
                            focus: mediaAttribute.focus
                        )
                    )
                }
            }
            try await group.waitForAll()
        }
    }

    /// Gets a single post
    /// - Parameter id: the ID of the post to be retrieved
    /// - Returns: the post retrieved, if successful, throws an error if not
    public func getPost(id: String) async throws -> Post {
        let response = try await getPostRaw(id: id)
        return response.data
    }

    /// Gets a single post with HTTP response metadata
    /// - Parameter id: the ID of the post to be retrieved
    /// - Returns: TootResponse containing the post and HTTP metadata
    public func getPostRaw(id: String) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .get
        }
        return try await fetchRaw(Post.self, req)
    }

    /// View statuses above and below this post in the thread.
    ///
    /// Public for public posts limited to 40 ancestors and 60 descendants with a maximum depth of 20. User token + read:statuses for up to 4,096 ancestors, 4,096 descendants, unlimited depth, and private posts.
    public func getContext(id: String) async throws -> Context {
        let response = try await getContextRaw(id: id)
        return response.data
    }

    /// View statuses above and below this post in the thread with HTTP response metadata
    ///
    /// Public for public posts limited to 40 ancestors and 60 descendants with a maximum depth of 20. User token + read:statuses for up to 4,096 ancestors, 4,096 descendants, unlimited depth, and private posts.
    public func getContextRaw(id: String) async throws -> TootResponse<Context> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "context"])
            $0.method = .get
        }
        return try await fetchRaw(Context.self, req)
    }
}

extension TootClient {

    /// Deletes a single post
    /// - Parameter id: the ID of the post to be deleted
    /// - Parameter deleteMedia: Whether to immediately delete the post's media attachments. Only supported if ``InstanceV2/apiVersions-swift.property`` includes ``InstanceV2/APIVersions-swift.struct/mastodon`` API version 4 or higher. If supported and this parameter is `nil` or `false`, media attachents may be kept for approximately 24 hours so they can be reused in a new post.
    /// - Returns: the post deleted (for delete and redraft), if successful, throws an error if not
    public func deletePost(id: String, deleteMedia: Bool? = nil) async throws -> Post {
        let response = try await deletePostRaw(id: id, deleteMedia: deleteMedia)
        return response.data
    }

    /// Deletes a single post with HTTP response metadata
    /// - Parameter id: the ID of the post to be deleted
    /// - Parameter deleteMedia: Whether to immediately delete the post's media attachments. Only supported if ``InstanceV2/apiVersions-swift.property`` includes ``InstanceV2/APIVersions-swift.struct/mastodon`` API version 4 or higher. If supported and this parameter is `nil` or `false`, media attachents may be kept for approximately 24 hours so they can be reused in a new post.
    /// - Returns: TootResponse containing the post deleted (for delete and redraft) and HTTP metadata
    public func deletePostRaw(id: String, deleteMedia: Bool? = nil) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .delete
            if let deleteMedia {
                $0.addQueryParameter(name: "delete_media", value: String(deleteMedia))
            }
        }
        return try await fetchRaw(Post.self, req)
    }

}

extension TootClient {

    public func favouritePost(id: String) async throws -> Post {
        let response = try await favouritePostRaw(id: id)
        return response.data
    }

    public func favouritePostRaw(id: String) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "favourite"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

    public func unfavouritePost(id: String) async throws -> Post {
        let response = try await unfavouritePostRaw(id: id)
        return response.data
    }

    public func unfavouritePostRaw(id: String) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unfavourite"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

}

extension TootClient {

    /// Reshare a post on your own profile.
    public func boostPost(id: String) async throws -> Post {
        let response = try await boostPostRaw(id: id)
        return response.data
    }

    /// Reshare a post on your own profile with HTTP response metadata.
    public func boostPostRaw(id: String) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "reblog"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

    /// Undo a reshare of a post.
    public func unboostPost(id: String) async throws -> Post {
        let response = try await unboostPostRaw(id: id)
        return response.data
    }

    /// Undo a reshare of a post with HTTP response metadata.
    public func unboostPostRaw(id: String) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unreblog"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

}

extension TootClient {

    /// Privately bookmark a post.
    public func bookmarkPost(id: String) async throws -> Post {
        let response = try await bookmarkPostRaw(id: id)
        return response.data
    }

    /// Privately bookmark a post with HTTP response metadata.
    public func bookmarkPostRaw(id: String) async throws -> TootResponse<Post> {
        try requireFeature(.bookmark)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "bookmark"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

    /// Remove a post from your private bookmarks.
    public func unbookmarkPost(id: String) async throws -> Post {
        let response = try await unbookmarkPostRaw(id: id)
        return response.data
    }

    /// Remove a post from your private bookmarks with HTTP response metadata.
    public func unbookmarkPostRaw(id: String) async throws -> TootResponse<Post> {
        try requireFeature(.bookmark)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unbookmark"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

}

extension TootClient {

    /// Do not receive notifications for the thread that this post is part of. Must be a thread in which you are a participant.
    public func mutePost(id: String) async throws -> Post {
        let response = try await mutePostRaw(id: id)
        return response.data
    }

    /// Do not receive notifications for the thread that this post is part of with HTTP response metadata. Must be a thread in which you are a participant.
    public func mutePostRaw(id: String) async throws -> TootResponse<Post> {
        try requireFeature(.mutePost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "mute"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

    /// Start receiving notifications again for the thread that this post is part of.
    public func unmutePost(id: String) async throws -> Post {
        let response = try await unmutePostRaw(id: id)
        return response.data
    }

    /// Start receiving notifications again for the thread that this post is part of with HTTP response metadata.
    public func unmutePostRaw(id: String) async throws -> TootResponse<Post> {
        try requireFeature(.mutePost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unmute"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }
}

extension TootClient {

    /// Feature one of your own public posts at the top of your profile.
    public func pinPost(id: String) async throws -> Post {
        let response = try await pinPostRaw(id: id)
        return response.data
    }

    /// Feature one of your own public posts at the top of your profile with HTTP response metadata.
    public func pinPostRaw(id: String) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "pin"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }

    /// Unfeature a post from the top of your profile.
    public func unpinPost(id: String) async throws -> Post {
        let response = try await unpinPostRaw(id: id)
        return response.data
    }

    /// Unfeature a post from the top of your profile with HTTP response metadata.
    public func unpinPostRaw(id: String) async throws -> TootResponse<Post> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unpin"])
            $0.method = .post
        }
        return try await fetchRaw(Post.self, req)
    }
}

extension TootClient {

    /// View who boosted a given post.
    public func getAccountsBoosted(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let response = try await getAccountsBoostedRaw(id: id, pageInfo, limit: limit)
        return response.data
    }

    /// View who boosted a given post with HTTP response metadata.
    public func getAccountsBoostedRaw(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> TootResponse<
        PagedResult<[Account]>
    > {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "reblogged_by"])
            $0.method = .get
            if flavour == .mastodon {
                $0.query = getQueryParams(pageInfo, limit: limit)
            }
        }
        return try await fetchPagedResultRaw(req)
    }

    /// View who favourited a given post.
    public func getAccountsFavourited(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let response = try await getAccountsFavouritedRaw(id: id, pageInfo, limit: limit)
        return response.data
    }

    /// View who favourited a given post with HTTP response metadata.
    public func getAccountsFavouritedRaw(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> TootResponse<
        PagedResult<[Account]>
    > {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "favourited_by"])
            $0.method = .get
            if flavour == .mastodon {
                $0.query = getQueryParams(pageInfo, limit: limit)
            }
        }

        return try await fetchPagedResultRaw(req)
    }

}

extension TootClient {

    /// Get all known versions of a post, including the initial and current states.
    public func getHistory(id: String) async throws -> [PostEdit] {
        let response = try await getHistoryRaw(id: id)
        return response.data
    }

    /// Get all known versions of a post, including the initial and current states with HTTP response metadata.
    public func getHistoryRaw(id: String) async throws -> TootResponse<[PostEdit]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "history"])
            $0.method = .get
        }

        let response = try await fetchRaw([PostEdit].self, req)
        let filteredPostEdits = response.data.compactMap({ $0 })
        return TootResponse(
            data: filteredPostEdits,
            headers: response.headers,
            statusCode: response.statusCode,
            url: response.url,
            rawBody: response.rawBody
        )
    }

}

extension TootClient {

    /// Obtain the source properties for a post so that it can be edited.
    public func getPostSource(id: String) async throws -> PostSource {
        let response = try await getPostSourceRaw(id: id)
        return response.data
    }

    /// Obtain the source properties for a post so that it can be edited with HTTP response metadata.
    public func getPostSourceRaw(id: String) async throws -> TootResponse<PostSource> {
        try requireFlavour(otherThan: [.pixelfed])

        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "source"])
            $0.method = .get
        }

        return try await fetchRaw(PostSource.self, req)
    }

}

extension TootClient {

    /// Translate the post content into some language.
    public func getPostTranslation(id: String, params: PostTranslationParams? = nil) async throws -> Translation {
        let response = try await getPostTranslationRaw(id: id, params: params)
        return response.data
    }

    /// Translate the post content into some language with HTTP response metadata.
    public func getPostTranslationRaw(id: String, params: PostTranslationParams? = nil) async throws -> TootResponse<Translation> {
        try requireFeature(.translatePost)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "translate"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }
        return try await fetchRaw(Translation.self, req)
    }
}

extension TootFeature {

    /// Ability to bookmark posts
    ///
    public static let bookmark = TootFeature(supportedFlavours: [
        .mastodon, .akkoma, .pleroma, .pixelfed, .friendica, .firefish, .goToSocial, .catodon, .iceshrimp,
    ])
}

extension TootFeature {

    /// Ability to mute a conversation that mentions you
    ///
    public static let mutePost = TootFeature(supportedFlavours: [
        .mastodon, .akkoma, .pleroma, .pixelfed, .friendica, .firefish, .goToSocial, .catodon, .iceshrimp,
    ])
}

extension TootFeature {

    /// Ability to translate a post
    ///
    public static let translatePost = TootFeature(supportedFlavours: [.mastodon])
}
