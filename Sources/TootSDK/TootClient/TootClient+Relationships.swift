// Created by konstantin on 21/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

extension TootClient {
    /// Follow the given account. Can also be used to update whether to show reblogs or enable notifications.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func followAccount(by id: String, params: FollowAccountParams? = nil) async throws -> Relationship {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "follow"])
            $0.method = .post
            $0.body = try .json(params)
        }
        return try await fetch(Relationship.self, req)
    }
        
    /// Follow the given account; can be be the account name on the instance you're on, or the user's URI
    /// - Parameter uri: account name on the instance you're on or a users URI (e.g @test@instance.test)
    /// - Returns: your relationship with that account after following
    public func followAccountURI(by uri: String) async throws -> Relationship {
        switch self.flavour {
        case .mastodon:
            // Do the webfinger lookup first, then go and follow by account afterwards
            let accountLookup = try await lookupAccount(uri: uri)
            return try await followAccount(by: accountLookup.id)
        case .pleroma:
            // swiftlint:disable todo
            // TODO: - resolve this issue: https://github.com/TootSDK/TootSDK/issues/34
            
            // On Pleroma, we get to follow by URI, but it doesn't return a relationship, it returns an account
            // So we use that to then retrieve the relationship
            let account = try await pleromaFollowAccountURI(by: uri)
            
            if let relationship = try await getRelationships(by: [account.id]).first {
                return relationship
            } else {
                throw TootSDKError.unexpectedError("Unable to retrieve relationship")
            }
        }
    }
    
    /// Mastodon Specific. Looks up an account based on it's account name or URI, and returns a payload that containts the instance's account id
    /// - Parameter uri: account name on the instance you're on or a users URI (e.g @test@instance.test)
    /// - Returns: AccountLookup, a payload containing information about the account looked up
    public func lookupAccount(uri: String) async throws -> AccountLookup {
        guard flavour == .mastodon else { throw TootSDKError.unsupportedFlavour(current: flavour, required: [.mastodon]) }
        
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "lookup"])
            $0.method = .get
            $0.addQueryParameter(name: "acct", value: uri)
        }
        
        return try await fetch(AccountLookup.self, req)
    }
    
    /// Pleroma Specific. This follows an account by URI and returns the account being followed
    /// - Parameter uri: account name on the instance you're on or a users URI (e.g @test@instance.test)
    /// - Returns: the Account being followed
    private func pleromaFollowAccountURI(by uri: String) async throws -> Relationship {
        guard flavour == .pleroma else { throw TootSDKError.unsupportedFlavour(current: flavour, required: [.pleroma]) }

        let params = PleromaFollowByURIParams(uri: uri)
        
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "follows"])
            $0.method = .post
            $0.body = try .json(params)
        }
        return try await fetch(Relationship.self, req)
    }
        
    /// Unfollow the given account.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func unfollowAccount(by id: String) async throws -> Relationship {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "unfollow"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Remove the given account from your followers.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func removeAccountFromFollowers(by id: String) async throws -> Relationship {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "remove_from_followers"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Block the given account. Clients should filter statuses from this account if received (e.g. due to a boost in the Home timeline)
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func blockAccount(by id: String) async throws -> Relationship {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "block"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Unblock the given account
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func unblockAccount(by id: String) async throws -> Relationship {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "unblock"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Mute the given account. Clients should filter statuses and notifications from this account, if received (e.g. due to a boost in the Home timeline).
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func muteAccount(by id: String, params: MuteAccountParams? = nil) async throws -> Relationship {
        let req = try HTTPRequestBuilder {
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
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "unmute"])
            $0.method = .post
        }
        return try await fetch(Relationship.self, req)
    }
    
    /// Find out whether a given account is followed, blocked, muted, etc.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the relationship to the account requested, or an error if unable to retrieve
    public func getRelationships(by ids: [String]) async throws -> [Relationship] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "relationships"])
            $0.method = .get
            $0.query = ids.map({URLQueryItem(name: "id", value: $0)})
        }
        return try await fetch([Relationship].self, req)
    }
    
}
