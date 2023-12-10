//
//  TootClient+FollowRequests.swift
//  
//
//  Created by Łukasz Rutkowski on 10/12/2023.
//

import Foundation

public extension TootClient {

    /// Get pending follow requests.
    ///
    /// - Parameters:
    ///    - pageInfo: PagedInfo object for max/since.
    ///    - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: The accounts that are requesting a follow.
    func getPendingFollowRequests(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> [Account] {
        try requireFeature(.followRequests)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follow_requests"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        return try await fetch([Account].self, req)
    }

    /// Accept a follow request.
    ///
    /// - Parameter id: The id of the account received from ``getPendingFollowRequests``.
    /// - Returns: Relationship with the account.
    @discardableResult
    func acceptFollowRequest(id: String) async throws -> Relationship {
        try requireFeature(.followRequests)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follow_requests", id, "authorize"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }

    /// Reject a follow request.
    ///
    /// - Parameter id: The id of the account received from ``getPendingFollowRequests``.
    /// - Returns: Relationship with the account.
    @discardableResult
    func rejectFollowRequest(id: String) async throws -> Relationship {
        try requireFeature(.followRequests)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follow_requests", id, "reject"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
}

extension TootFeature {
    
    /// Ability to view and manage follow requests.
    public static let followRequests = TootFeature(supportedFlavours: [.mastodon, .pleroma, .pixelfed, .friendica, .akkoma, .firefish])
}
