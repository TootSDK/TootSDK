//  TootClient+ScheduledPost.swift
//  Created by dave on 7/12/22.

import Foundation

public extension TootClient {

    /// Schedules a post based on the components provided
    /// - Parameters:
    ///   - ScheduledPostParams: post components to be published
    /// - Returns: the ScheduledPost, if successful, throws an error if not
    func schedulePost(_ params: ScheduledPostParams) async throws -> ScheduledPost {
        let requestParams = try ScheduledPostRequest(from: params)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses"])
            $0.method = .post
            $0.body = try .multipart(requestParams, boundary: UUID().uuidString)
        }

        return try await fetch(ScheduledPost.self, req)
    }

    /// Gets scheduled posts
    /// - Parameters:
    ///   - minId: Return results immediately newer than ID.
    ///   - maxId: Return results older than ID
    ///   - sinceId: Return results newer than ID
    ///   - limit: Maximum number of results to return. Defaults to 20. Max 40
    /// - Returns: array of scheduled posts (empty if none), an error if any issue
    func getScheduledPost(minId: String?, maxId: String?, sinceId: String?, limit: Int?) async throws -> [ScheduledPost] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses"])
            $0.method = .get

            if let minId {
                $0.addQueryParameter(name: "min_id", value: minId)
            }

            if let maxId {
                $0.addQueryParameter(name: "max_id", value: maxId)
            }

            if let sinceId {
                $0.addQueryParameter(name: "since_id", value: sinceId)
            }

            if let limit {
                $0.addQueryParameter(name: "limit", value: String(limit))
            }
        }

        return try await fetch([ScheduledPost].self, req)
    }

    /// Gets a single Scheduled post by id
    ///
    /// - Parameter id: the ID of the post to be retrieved
    /// - Returns: the scheduled post retrieved, if successful, throws an error if not
    func getScheduledPost(id: String) async throws -> ScheduledPost? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .get
        }

        return try await fetch(ScheduledPost.self, req)
    }

    /// Edit a given post to change its text, sensitivity, media attachments, or poll. Note that editing a poll’s options will reset the votes.
    /// - Parameter id: the ID of the post to be changed
    /// - Parameter params: the updated content of the post to be posted
    /// - Returns: the post after the update
    func updateScheduledPostDate(id: String, _ params: ScheduledPostParams) async throws -> ScheduledPost? {
        let requestParams = try ScheduledPostRequest(from: params)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .put
            $0.body = try .multipart(requestParams, boundary: UUID().uuidString)
        }

        return try await fetch(ScheduledPost.self, req)
    }

    /// Deletes a single scheduled post
    /// - Parameter id: the ID of the post to be deleted
    /// - Returns: the post deleted (for delete and redraft), if successful, throws an error if not
    func deleteScheduledPost(id: String) async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

}
