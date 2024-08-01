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
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses"])
            $0.method = .post
            $0.body = try .multipart(params, boundary: UUID().uuidString)
        }
        return try await fetch(Post.self, req)
    }

    /// Edit a given post to change its text, sensitivity, media attachments, or poll. Note that editing a poll’s options will reset the votes.
    ///
    /// - Note: For Pixelfed this will first attempt to update media descriptions and then update rest of post details.
    /// If an error is thrown it is possible for some of the media descriptions to be already successfully updated.
    ///
    /// - Parameter id: The ID of the post to be changed.
    /// - Parameter params: The updated content of the post to be posted.
    /// - Returns: The post after the update.
    public func editPost(id: String, _ params: EditPostParams) async throws -> Post {
        let updateMediaSeparately = [.pixelfed, .pleroma, .akkoma, .firefish, .catodon, .iceshrimp].contains(flavour)
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
            return try await getPost(id: id)
        }
        return try await fetch(Post.self, req)
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
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .get
        }
        return try await fetch(Post.self, req)
    }

    /// View statuses above and below this post in the thread.
    ///
    /// Public for public posts limited to 40 ancestors and 60 descendants with a maximum depth of 20. User token + read:statuses for up to 4,096 ancestors, 4,096 descendants, unlimited depth, and private posts.
    public func getContext(id: String) async throws -> Context {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "context"])
            $0.method = .get
        }
        return try await fetch(Context.self, req)
    }
}

extension TootClient {

    /// Deletes a single post
    /// - Parameter id: the ID of the post to be deleted
    /// - Returns: the post deleted (for delete and redraft), if successful, throws an error if not
    public func deletePost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .delete
        }
        return try await fetch(Post.self, req)
    }

}

extension TootClient {

    public func favouritePost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "favourite"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

    public func unfavouritePost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unfavourite"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

}

extension TootClient {

    /// Reshare a post on your own profile.
    public func boostPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "reblog"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

    /// Undo a reshare of a post.
    public func unboostPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unreblog"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

}

extension TootClient {

    /// Privately bookmark a post.
    public func bookmarkPost(id: String) async throws -> Post {
        try requireFeature(.bookmark)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "bookmark"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

    /// Remove a post from your private bookmarks.
    public func unbookmarkPost(id: String) async throws -> Post {
        try requireFeature(.bookmark)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unbookmark"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

}

extension TootClient {

    /// Do not receive notifications for the thread that this post is part of. Must be a thread in which you are a participant.
    public func mutePost(id: String) async throws -> Post {
        try requireFeature(.mutePost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "mute"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

    /// Start receiving notifications again for the thread that this post is part of.
    public func unmutePost(id: String) async throws -> Post {
        try requireFeature(.mutePost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unmute"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
}

extension TootClient {

    /// Feature one of your own public posts at the top of your profile.
    public func pinPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "pin"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }

    /// Unfeature a post from the top of your profile.
    public func unpinPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unpin"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
}

extension TootClient {

    /// View who boosted a given post.
    public func getAccountsBoosted(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "reblogged_by"])
            $0.method = .get
            if flavour == .mastodon {
                $0.query = getQueryParams(pageInfo, limit: limit)
            }
        }
        return try await fetchPagedResult(req)
    }

    /// View who favourited a given post.
    public func getAccountsFavourited(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "favourited_by"])
            $0.method = .get
            if flavour == .mastodon {
                $0.query = getQueryParams(pageInfo, limit: limit)
            }
        }

        return try await fetchPagedResult(req)
    }

}

extension TootClient {

    /// Get all known versions of a post, including the initial and current states.
    public func getHistory(id: String) async throws -> [PostEdit] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "history"])
            $0.method = .get
        }

        let postEdits = try await fetch([PostEdit].self, req)
        return postEdits.compactMap({ $0 })
    }

}

extension TootClient {

    /// Obtain the source properties for a post so that it can be edited.
    public func getPostSource(id: String) async throws -> PostSource {
        try requireFlavour(otherThan: [.pixelfed])

        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "source"])
            $0.method = .get
        }

        return try await fetch(PostSource.self, req)
    }

}

extension TootClient {

    /// Translate the post content into some language.
    public func getPostTranslation(id: String, params: PostTranslationParams? = nil) async throws -> Translation {
        try requireFeature(.translatePost)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "translate"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }
        return try await fetch(Translation.self, req)
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
