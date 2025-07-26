//
//  TootClient+FollowRequests.swift
//
//
//  Created by Łukasz Rutkowski on 10/12/2023.
//

import Foundation

extension TootClient {

    /// Get pending follow requests.
    ///
    /// - Parameters:
    ///    - pageInfo: PagedInfo object for max/since.
    ///    - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: The accounts that are requesting a follow.
    @available(*, deprecated, renamed: "getFollowRequests")
    public func getPendingFollowRequests(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> [Account] {
        let response = try await getPendingFollowRequestsRaw(pageInfo, limit: limit)
        return response.data
    }

    /// Get pending follow requests with HTTP response metadata
    ///
    /// - Parameters:
    ///    - pageInfo: PagedInfo object for max/since.
    ///    - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: TootResponse containing the accounts that are requesting a follow and HTTP metadata
    @available(*, deprecated, renamed: "getFollowRequestsRaw")
    public func getPendingFollowRequestsRaw(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> TootResponse<[Account]> {
        try requireFeature(.followRequests)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follow_requests"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        return try await fetchRaw([Account].self, req)
    }

    /// Get pending follow requests.
    ///
    /// - Parameters:
    ///    - pageInfo: PagedInfo object for max/since.
    ///    - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: The accounts that are requesting a follow. Some server flavours may ignore the limit and return all requests.
    public func getFollowRequests(_ pageInfo: PagedInfo? = nil, limit: Int = 40) async throws -> PagedResult<[Account]> {
        let response = try await getFollowRequestsRaw(pageInfo, limit: limit)
        return response.data
    }

    /// Get pending follow requests with HTTP response metadata
    ///
    /// - Parameters:
    ///    - pageInfo: PagedInfo object for max/since.
    ///    - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: TootResponse containing the accounts that are requesting a follow and HTTP metadata
    public func getFollowRequestsRaw(_ pageInfo: PagedInfo? = nil, limit: Int = 40) async throws -> TootResponse<PagedResult<[Account]>> {
        let requestLimit = min(limit, 80)
        try requireFeature(.followRequests)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follow_requests"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: requestLimit)
        }
        return try await fetchPagedResultRaw(req)
    }

    /// Accept a follow request.
    ///
    /// - Parameter id: The id of the account received from ``getPendingFollowRequests``.
    /// - Returns: Relationship with the account.
    @discardableResult
    public func acceptFollowRequest(id: String) async throws -> Relationship {
        let response = try await acceptFollowRequestRaw(id: id)
        return response.data
    }

    /// Accept a follow request with HTTP response metadata
    ///
    /// - Parameter id: The id of the account received from ``getPendingFollowRequests``.
    /// - Returns: TootResponse containing the relationship with the account and HTTP metadata
    @discardableResult
    public func acceptFollowRequestRaw(id: String) async throws -> TootResponse<Relationship> {
        try requireFeature(.followRequests)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follow_requests", id, "authorize"])
            $0.method = .post
        }
        return try await fetchRaw(Relationship.self, req)
    }

    /// Reject a follow request.
    ///
    /// - Parameter id: The id of the account received from ``getPendingFollowRequests``.
    /// - Returns: Relationship with the account.
    @discardableResult
    public func rejectFollowRequest(id: String) async throws -> Relationship {
        let response = try await rejectFollowRequestRaw(id: id)
        return response.data
    }

    /// Reject a follow request with HTTP response metadata
    ///
    /// - Parameter id: The id of the account received from ``getPendingFollowRequests``.
    /// - Returns: TootResponse containing the relationship with the account and HTTP metadata
    @discardableResult
    public func rejectFollowRequestRaw(id: String) async throws -> TootResponse<Relationship> {
        try requireFeature(.followRequests)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follow_requests", id, "reject"])
            $0.method = .post
        }
        return try await fetchRaw(Relationship.self, req)
    }
}

extension TootFeature {

    /// Ability to view and manage follow requests.
    public static let followRequests = TootFeature(supportedFlavours: [
        .mastodon, .pleroma, .pixelfed, .friendica, .akkoma, .firefish, .sharkey, .goToSocial, .catodon, .iceshrimp,
    ])
}
