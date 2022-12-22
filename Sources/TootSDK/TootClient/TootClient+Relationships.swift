// Created by konstantin on 21/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

extension TootClient {
    /// Follow the given account. Can also be used to update whether to show reblogs or enable notifications.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func followAccount(by id: String, params: FollowAccountParams? = nil) async throws -> Relationship {
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "follow"])
            $0.method = .post
            $0.body = try .json(params)
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Unfollow the given account.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func unfollowAccount(by id: String) async throws -> Relationship {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "unfollow"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Remove the given account from your followers.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func removeAccountFromFollowers(by id: String) async throws -> Relationship {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "remove_from_followers"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Block the given account. Clients should filter statuses from this account if received (e.g. due to a boost in the Home timeline)
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func blockAccount(by id: String) async throws -> Relationship {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "block"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Unblock the given account
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func unblockAccount(by id: String) async throws -> Relationship {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "unblock"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Mute the given account. Clients should filter statuses and notifications from this account, if received (e.g. due to a boost in the Home timeline).
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func muteAccount(by id: String, params: MuteAccountParams? = nil) async throws -> Relationship {
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "mute"])
            $0.method = .post
            $0.body = try .json(params)
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Unmute the given account.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func unmuteAccount(by id: String) async throws -> Relationship {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "unmute"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Find out whether a given account is followed, blocked, muted, etc.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func getRelationships(by ids: [String]) async throws -> [Relationship] {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "relationships"])
            $0.method = .get
            $0.query = ids.map({URLQueryItem(name: "id", value: $0)})
        }
        return try await fetch([Relationship].self, req)
    }
    
}
