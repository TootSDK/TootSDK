//
//  TootClient+Account.swift
//  
//
//  Created by dave on 25/11/22.
//

import Foundation

extension TootClient {
    
    /// A test to make sure that the user token works, and retrieves the account information
    /// - Returns: Returns the current authenticated user's account, or throws an error if unable to retrieve
    public func verifyCredentials() async throws -> Account {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "verify_credentials"])
            $0.method = .get
        }
        return try await fetch(Account.self, req)
    }
    
    /// View information about a profile.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the account requested, or an error if unable to retrieve
    public func getAccount(by id: String) async throws -> Account {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id])
            $0.method = .get
        }
        return try await fetch(Account.self, req)
    }
    
    /// Follow the given account. Can also be used to update whether to show reblogs or enable notifications.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func followAccount(by id: String, params: FollowAccountParams = FollowAccountParams()) async throws -> Relationship {
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "follow"])
            $0.method = .post
            $0.body = try .multipart(params, boundary: UUID().uuidString)
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
    public func muteAccount(by id: String) async throws -> Relationship {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "mute"])
            $0.method = .post
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
        let req = HttpRequestBuilder { request in
            request.url = getURL(["api", "v1", "accounts", "relationships"])
            request.method = .get
            
            ids.forEach { id in
                request.addQueryParameter(name: "id[]", value: id)
            }
        }
        return try await fetch([Relationship].self, req)
    }
    
    // TODO: - Register an account
    // TODO: - Update account credentials
    
    // TODO: - Get account’s statuses
    // TODO: - Get account’s followers
    // TODO: - Get account’s following
    // TODO: - Get account’s featured tags
    // TODO: - Get lists containing this account
    // TODO: - Feature account on your profile
    // TODO: - Unfeature account from profile
    // TODO: - Set private note on profile
    
    // TODO: - Find familiar followers
    // TODO: - Search for matching accounts
    // TODO: - Lookup account ID from Webfinger address
}
