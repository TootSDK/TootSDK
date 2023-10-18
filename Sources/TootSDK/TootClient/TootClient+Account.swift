//
//  TootClient+Account.swift
//
//
//  Created by dave on 25/11/22.
//

import Foundation
import MultipartKitTootSDK

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

    /// Update the user’s display and preferences.
    /// - Returns: The user’s own Account with source attribute
    public func updateCredentials(params: UpdateCredentialsParams) async throws -> Account {
        try requireFeature(.updateCredentials)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "update_credentials"])
            if self.flavour == .pixelfed {
                // https://github.com/pixelfed/pixelfed/issues/4250#issuecomment-1483798056
                $0.method = .post
            } else {
                $0.method = .patch
            }
            var parts = [MultipartPart]()
            if let data = params.avatar,
               let mimeType = params.avatarMimeType {
                parts.append(
                    MultipartPart(
                        file: "avatar",
                        mimeType: mimeType,
                        body: data))
            }
            if let data = params.header,
               let mimeType = params.headerMimeType {
                parts.append(
                    MultipartPart(
                        file: "header",
                        mimeType: mimeType,
                        body: data))
            }
            if let name = params.displayName {
                parts.append(
                    MultipartPart(name: "display_name", body: name))
            }
            if let note = params.note {
                parts.append(
                    MultipartPart(name: "note", body: note))
            }
            if let locked = params.locked {
                parts.append(
                    MultipartPart(
                        name: "locked",
                        body: String(locked)))
            }
            if let bot = params.bot {
                parts.append(
                    MultipartPart(
                        name: "bot",
                        body: String(bot)))
            }
            if let discoverable = params.discoverable {
                parts.append(
                    MultipartPart(
                        name: "discoverable",
                        body: String(discoverable)))
            }
            parts.append(contentsOf: getFieldParts(params))
            parts.append(contentsOf: getSourceParts(params))
            $0.body = try .multipart(parts, boundary: UUID().uuidString)
        }
        return try await fetch(Account.self, req)
    }

    func getFieldParts(_ params: UpdateCredentialsParams) -> [MultipartPart] {
        var parts = [MultipartPart]()
        if let fields = params.fieldsAttributes {
            for (key, field) in fields {
                parts.append(
                    MultipartPart(
                        name: "fields_attributes[\(key)][name]",
                        body: field.name))
                parts.append(
                    MultipartPart(
                        name: "fields_attributes[\(key)][value]",
                        body: field.value))
            }
        }
        return parts
    }

    func getSourceParts(_ params: UpdateCredentialsParams) -> [MultipartPart] {
        var parts = [MultipartPart]()
        if let privacy = params.source?.privacy {
            parts.append(
                MultipartPart(
                    name: "source[privacy]",
                    body: privacy.rawValue))
        }
        if let sensitive = params.source?.sensitive {
            parts.append(
                MultipartPart(
                    name: "source[sensitive]",
                    body: String(sensitive)))
        }
        if let language = params.source?.language {
            parts.append(
                MultipartPart(
                    name: "source[language]",
                    body: language))
        }
        return parts
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
    /// - Parameters
    ///     - id: the ID of the Account in the instance database.
    ///     - pageInfo: PagedInfo object for max/min/since
    ///     - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: the accounts requested, or an error if unable to retrieve
    public func getFollowers(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil)
    async throws -> PagedResult<[Account]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "followers"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
    }

    /// Get all accounts which the given account is following, if network is not hidden by the account owner.
    /// - Parameters:
    ///     - id: the ID of the Account in the instance database.
    ///     - pageInfo: PagedInfo object for max/min/since
    ///     - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: the accounts requested, or an error if unable to retrieve
    public func getFollowing(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil)
    async throws -> PagedResult<[Account]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "following"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
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
                if let decoded = try? decode(RegisterAccountErrors.self, from: data),
                   let message = decoded.error {
                    throw TootSDKError.serverError(message)
                }
            }
            throw error
        }
    }

    /// Search for matching accounts by username or display name.
    ///
    /// - Parameters:
    ///   - params: The search parameters.
    ///   - limit: Maximum number of results to return. Defaults to 40. Max 80 accounts.
    ///   - offset: Skip the first n results.
    /// - Returns: Search results.
    public func searchAccounts(params: SearchAccountsParams, limit: Int? = nil, offset: Int? = nil)
    async throws -> [Account] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "search"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset) + params.queryItems
        }
        return try await fetch([Account].self, req)
    }

    /// Retrieve lists in which the given account `id` is present
    public func getListsContainingAccount(id: String) async throws -> [List] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "lists"])
            $0.method = .get
        }

        return try await fetch([List].self, req)
    }

    // swiftlint:disable todo
    // TODO: - Lookup account ID from Webfinger address
    // swiftlint:enable todo
}

extension TootFeature {

    /// Ability to edit your profile
    ///
    public static let updateCredentials = TootFeature(supportedFlavours: [.mastodon, .akkoma, .pleroma, .pixelfed])
}
