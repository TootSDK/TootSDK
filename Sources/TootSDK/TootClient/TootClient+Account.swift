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
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "verify_credentials"])
            $0.method = .get
        }
        return try await fetch(Account.self, req)
    }
    
    /// View information about a profile.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the account requested, or an error if unable to retrieve
    public func getAccount(by id: String) async throws -> Account {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id])
            $0.method = .get
        }
        return try await fetch(Account.self, req)
    }
    
    /// Get all accounts which follow the given account, if network is not hidden by the account owner.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the accounts requested, or an error if unable to retrieve
    public func getFollowers(for id: String) async throws -> [Account] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "followers"])
            $0.method = .get
        }
        return try await fetch([Account].self, req)
    }
    
    /// Get all accounts which the given account is following, if network is not hidden by the account owner.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the accounts requested, or an error if unable to retrieve
    public func getFollowing(for id: String) async throws -> [Account] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "following"])
            $0.method = .get
        }
        return try await fetch([Account].self, req)
    }
    
    // swiftlint:disable todo
    // TODO: - Register an account
    // TODO: - Update account credentials
    
    // TODO: - Get account’s posts
    // TODO: - Get account’s featured tags
    // TODO: - Get lists containing this account
    // TODO: - Feature account on your profile
    // TODO: - Unfeature account from profile
    // TODO: - Set private note on profile
    
    // TODO: - Find familiar followers
    // TODO: - Search for matching accounts
    // TODO: - Lookup account ID from Webfinger address
}
