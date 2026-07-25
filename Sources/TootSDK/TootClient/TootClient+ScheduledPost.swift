//  TootClient+ScheduledPost.swift
//  Created by dave on 7/12/22.

import Foundation

extension TootClient {

    /// Schedules a post based on the components provided
    /// - Parameters:
    ///   - ScheduledPostParams: post components to be published
    /// - Returns: the ScheduledPost, if successful, throws an error if not
    public func schedulePost(_ params: ScheduledPostParams) async throws -> ScheduledPost {
        try requireFeature(.scheduledPost)
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
    @available(*, deprecated, renamed: "getScheduledPosts")
    public func getScheduledPost(minId: String?, maxId: String?, sinceId: String?, limit: Int?) async throws -> [ScheduledPost] {
        try requireFeature(.scheduledPost)
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

    /// Gets scheduled posts
    /// - Returns: the scheduled posts requested, or an error if unable to retrieve
    public func getScheduledPosts(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[ScheduledPost]> {
        try requireFeature(.scheduledPost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
    }

    /// Gets a single Scheduled post by id
    ///
    /// - Parameter id: the ID of the post to be retrieved
    /// - Returns: the scheduled post retrieved, if successful, throws an error if not
    public func getScheduledPost(id: String) async throws -> ScheduledPost? {
        try requireFeature(.scheduledPost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .get
        }

        return try await fetch(ScheduledPost.self, req)
    }

    /// Update a scheduled post's publication date.
    /// - Parameters:
    ///   - id: The ID of the scheduled post to update.
    ///   - params: Parameters containing the new publication date.
    /// - Returns: The scheduled post after the update.
    public func updateScheduledPostDate(id: String, _ params: ReschedulePostParams) async throws -> ScheduledPost? {
        let response = try await updateScheduledPostDateRaw(id: id, params)
        return response.data
    }

    /// Update a scheduled post's publication date with HTTP response metadata.
    /// - Parameters:
    ///   - id: The ID of the scheduled post to update.
    ///   - params: Parameters containing the new publication date.
    /// - Returns: TootResponse containing the scheduled post after the update and HTTP metadata.
    public func updateScheduledPostDateRaw(id: String, _ params: ReschedulePostParams) async throws -> TootResponse<ScheduledPost?> {
        try requireFeature(.scheduledPost)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .put
            $0.body = try .form(queryItems: params.queryItems())
        }

        return try await fetchRaw(ScheduledPost?.self, req)
    }

    /// Update a scheduled post's publication date.
    /// - Parameters:
    ///   - id: The ID of the scheduled post to update.
    ///   - params: The scheduled post parameters containing the new publication date.
    /// - Returns: The scheduled post after the update.
    @available(*, deprecated, message: "Use updateScheduledPostDate(id:_:) with ReschedulePostParams instead.")
    public func updateScheduledPostDate(id: String, _ params: ScheduledPostParams) async throws -> ScheduledPost? {
        guard let scheduledAt = params.scheduledAt else {
            throw TootSDKError.missingParameter(parameterName: "scheduledAt")
        }

        return try await updateScheduledPostDate(id: id, ReschedulePostParams(scheduledAt: scheduledAt))
    }

    /// Deletes a single scheduled post
    /// - Parameter id: the ID of the post to be deleted
    /// - Returns: the post deleted (for delete and redraft), if successful, throws an error if not
    public func deleteScheduledPost(id: String) async throws {
        try requireFeature(.scheduledPost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

}

extension TootFeature {

    /// Ability to schedule a post
    ///
    public static let scheduledPost = TootFeature(supportedFlavours: [.mastodon, .akkoma, .pleroma, .friendica])
}
