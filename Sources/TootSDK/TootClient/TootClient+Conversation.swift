//
//  TootClient+Conversation.swift
//
//
//  Created by Konstantin Kostov on 23/09/2023.
//

import Foundation

extension TootClient {

    /// Return all conversations.
    ///
    /// Direct conversations with other participants. (Currently, just threads containing a post with "direct" visibility.)
    public func getConversations(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Conversation]> {
        let response = try await getConversationsRaw(pageInfo, limit: limit)
        return response.data
    }

    /// Return all conversations with HTTP response metadata
    ///
    /// Direct conversations with other participants. (Currently, just threads containing a post with "direct" visibility.)
    /// - Returns: TootResponse containing paginated conversations and HTTP metadata
    public func getConversationsRaw(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> TootResponse<PagedResult<[Conversation]>> {
        try requireFeature(.conversations)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResultRaw(req)
    }

    /// Removes a conversation from your list of conversations.
    public func deleteConversation(id: String) async throws {
        try requireFeature(.conversations)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

    /// Mark a conversation as read
    public func setConversationAsRead(id: String) async throws -> Conversation {
        let response = try await setConversationAsReadRaw(id: id)
        return response.data
    }

    /// Mark a conversation as read with HTTP response metadata
    /// - Returns: TootResponse containing the updated conversation and HTTP metadata
    public func setConversationAsReadRaw(id: String) async throws -> TootResponse<Conversation> {
        try requireFeature(.conversations)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations", id, "read"])
            $0.method = .post
        }

        return try await fetchRaw(Conversation.self, req)
    }
}

extension TootFeature {

    /// Ability to retrieve conversations.
    ///
    public static let conversations = TootFeature(supportedFlavours: [
        .mastodon, .pleroma, .friendica, .akkoma, .pixelfed, .firefish, .sharkey, .goToSocial, .catodon, .iceshrimp,
    ])
}
