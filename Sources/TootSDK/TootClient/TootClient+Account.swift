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
    
    // swiftlint:disable todo
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
