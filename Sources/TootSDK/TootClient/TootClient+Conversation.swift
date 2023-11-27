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
        try requireFeature(.conversations)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
    }

    /// Removes a conversation from your list of conversations.
    func deleteConversation(id: String) async throws {
        try requireFeature(.conversations)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

    /// Mark a conversation as read
    func setConversationAsRead(id: String) async throws -> Conversation {
        try requireFeature(.conversations)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "conversations", id, "read"])
            $0.method = .post
        }

        return try await fetch(Conversation.self, req)
    }
}

extension TootFeature {

    /// Ability to retrieve conversations.
    ///
    public static let conversations = TootFeature(supportedFlavours: [.mastodon, .pleroma, .friendica, .akkoma, .pixelfed, .firefish])
}
