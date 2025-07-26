//
//  TootClient+Poll.swift
//
//
//  Created by Konstantin Kostov on 23/09/2023.
//

import Foundation

extension TootClient {

    /// Obtain a poll with the specified `id`.
    public func getPoll(id: Poll.ID) async throws -> Poll {
        let response = try await getPollRaw(id: id)
        return response.data
    }

    /// Obtain a poll with the specified `id` with HTTP response metadata
    /// - Returns: TootResponse containing the poll and HTTP metadata
    public func getPollRaw(id: Poll.ID) async throws -> TootResponse<Poll> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "polls", id])
            $0.method = .get
        }

        return try await fetchRaw(Poll.self, req)
    }

    /// Vote on a poll.
    ///
    /// - Parameters:
    ///   - id: The ID of the Poll.
    ///   - choices: Set of indices representing votes for each option (starting from 0).
    /// - Returns: The Poll that was voted on.
    @discardableResult
    public func votePoll(id: Poll.ID, choices: IndexSet) async throws -> Poll {
        let response = try await votePollRaw(id: id, choices: choices)
        return response.data
    }

    /// Vote on a poll with HTTP response metadata
    ///
    /// - Parameters:
    ///   - id: The ID of the Poll.
    ///   - choices: Set of indices representing votes for each option (starting from 0).
    /// - Returns: TootResponse containing the poll that was voted on and HTTP metadata
    @discardableResult
    public func votePollRaw(id: Poll.ID, choices: IndexSet) async throws -> TootResponse<Poll> {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "polls", id, "votes"])
            $0.method = .post
            $0.body = try .form(
                queryItems: choices.map { index in
                    URLQueryItem(name: "choices[]", value: "\(index)")
                })
        }

        return try await fetchRaw(Poll.self, req)
    }

}
