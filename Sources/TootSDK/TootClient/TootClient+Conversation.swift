//
//  TootClient+Conversation.swift
//
//
//  Created by Konstantin Kostov on 23/09/2023.
//

import Foundation

public extension TootClient {

    /// Return all conversations.
    ///
    /// Direct conversations with other participants. (Currently, just threads containing a post with "direct" visibility.)
    func getConversations(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Conversation]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
    }

    /// Removes a conversation from your list of conversations.
    func deleteConversation(id: String) async throws {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

    /// Removes a conversation from your list of conversations.
    func setConversationAsRead(id: String) async throws -> Conversation {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations", id, "read"])
            $0.method = .post
        }

        return try await fetch(Conversation.self, req)
    }
}
