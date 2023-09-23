//
//  TootClient+Poll.swift
//
//
//  Created by Konstantin Kostov on 23/09/2023.
//

import Foundation

public extension TootClient {

    /// Obtain a poll with the specified `id`.
    func getPoll(id: Poll.ID) async throws -> Poll {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "polls", id])
            $0.method = .get
        }

        return try await fetch(Poll.self, req)
    }

    /// Vote on a poll.
    ///
    /// - Parameters:
    ///   - id: The ID of the Poll.
    ///   - choices: Set of indices representing votes for each option (starting from 0).
    /// - Returns: The Poll that was voted on.
    @discardableResult
    func votePoll(id: Poll.ID, choices: IndexSet) async throws -> Poll {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "polls", id, "votes"])
            $0.method = .post
            $0.body = try .form(queryItems: choices.map { index in
                URLQueryItem(name: "choices[]", value: "\(index)")
            })
        }

        return try await fetch(Poll.self, req)
    }

}
