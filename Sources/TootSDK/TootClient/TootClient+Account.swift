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
    public func getFollowers(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "followers"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        let (data, response) = try await fetch(req: req)
        let decoded = try decode([Account].self, from: data)
        var pagination: Pagination?

        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }

        let info = PagedInfo(maxId: pagination?.maxId, minId: pagination?.minId, sinceId: pagination?.sinceId)

        return PagedResult(result: decoded, info: info)
    }

    /// Get all accounts which the given account is following, if network is not hidden by the account owner.
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: the accounts requested, or an error if unable to retrieve
    public func getFollowing(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "following"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        let (data, response) = try await fetch(req: req)
        let decoded = try decode([Account].self, from: data)
        var pagination: Pagination?

        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }

        let info = PagedInfo(maxId: pagination?.maxId, minId: pagination?.minId, sinceId: pagination?.sinceId)

        return PagedResult(result: decoded, info: info)
    }

    /// Attempts to register a user.
    ///
    /// Returns an account access token for the app that initiated the request. The app should save this token for later, and should wait for the user to confirm their account by clicking a link in their email inbox.
    public func registerAccount(params: RegisterAccountParams) async throws -> AccessToken {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }

        do {
            let (data, _) = try await fetch(req: req)
            return try decode(AccessToken.self, from: data)
        } catch {
            if case let TootSDKError.invalidStatusCode(data, _) = error {
                if let decoded = try? decode(RegisterAccountErrors.self, from: data), let message = decoded.error {
                    throw TootSDKError.serverError(message)
                }
            }
            throw error
        }
    }

    /// Get tags featured by user.
    ///
    /// - Parameter userID: ID of user in database.
    /// - Returns: The featured tags or an error if unable to retrieve.
    public func getFeaturedTags(forUser userID: String) async throws -> [FeaturedTag] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", userID, "featured_tags"])
            $0.method = .get
        }
        return try await fetch([FeaturedTag].self, req)
    }

    // swiftlint:disable todo
    // TODO: - Update account credentials

    // TODO: - Get lists containing this account
    // TODO: - Feature account on your profile
    // TODO: - Unfeature account from profile
    // TODO: - Set private note on profile

    // TODO: - Find familiar followers
    // TODO: - Search for matching accounts
    // TODO: - Lookup account ID from Webfinger address
    // swiftlint:enable todo
}
