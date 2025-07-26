//
//  TootClient+Account.swift
//
//
//  Created by dave on 25/11/22.
//

import Foundation
import MultipartKitTootSDK

extension TootClient {

    /// Requests the server to invalidate the app's authentication token
    ///
    /// - Parameters:
    ///   - clientId: The client ID, obtained during app registration.
    ///   - clientSecret: The client secret, obtained during app registration.
    public func logout(clientId: String, clientSecret: String) async throws {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["oauth", "revoke"])
            $0.method = .post
            $0.body = try .form(queryItems: [
                URLQueryItem(name: "client_id", value: clientId),
                URLQueryItem(name: "client_secret", value: clientSecret),
            ])
        }
        _ = try await fetch(req: req)
    }

    /// A test to make sure that the user token works, and retrieves the account information
    /// - Returns: Returns the current authenticated user's account, or throws an error if unable to retrieve
    public func verifyCredentials() async throws -> Account {
        let response = try await verifyCredentialsRaw()
        return response.data
    }

    /// A test to make sure that the user token works, and retrieves the account information with HTTP response metadata
    /// - Returns: TootResponse containing the current authenticated user's account and HTTP metadata
    public func verifyCredentialsRaw() async throws -> TootResponse<Account> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "verify_credentials"])
            $0.method = .get
        }
        return try await fetchRaw(Account.self, req)
    }

    /// Update the user's display and preferences.
    /// - Returns: The user's own Account with source attribute
    public func updateCredentials(params: UpdateCredentialsParams) async throws -> Account {
        let response = try await updateCredentialsRaw(params: params)
        return response.data
    }

    /// Update the user's display and preferences with HTTP response metadata
    /// - Returns: TootResponse containing the user's own Account with source attribute and HTTP metadata
    public func updateCredentialsRaw(params: UpdateCredentialsParams) async throws -> TootResponse<Account> {
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
                let mimeType = params.avatarMimeType
            {
                parts.append(
                    MultipartPart(
                        file: "avatar",
                        mimeType: mimeType,
                        body: data))
            }
            if let data = params.header,
                let mimeType = params.headerMimeType
            {
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
            if let hideCollections = params.hideCollections {
                parts.append(
                    MultipartPart(
                        name: "hide_collections",
                        body: String(hideCollections)))
            }
            if let indexable = params.indexable {
                parts.append(
                    MultipartPart(
                        name: "indexable",
                        body: String(indexable)))
            }
            parts.append(contentsOf: getFieldParts(params))
            parts.append(contentsOf: getSourceParts(params))
            $0.body = try .multipart(parts, boundary: UUID().uuidString)
        }
        return try await fetchRaw(Account.self, req)
    }

    /// Get preferences defined by the user in their account settings.
    public func getPreferences() async throws -> Preferences {
        let response = try await getPreferencesRaw()
        return response.data
    }

    /// Get preferences defined by the user in their account settings with HTTP response metadata
    /// - Returns: TootResponse containing user preferences and HTTP metadata
    public func getPreferencesRaw() async throws -> TootResponse<Preferences> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "preferences"])
            $0.method = .get
        }
        return try await fetchRaw(Preferences.self, req)
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
        let response = try await getAccountRaw(by: id)
        return response.data
    }

    /// View information about a profile with HTTP response metadata
    /// - Parameter id: the ID of the Account in the instance database.
    /// - Returns: TootResponse containing the account requested and HTTP metadata
    public func getAccountRaw(by id: String) async throws -> TootResponse<Account> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id])
            $0.method = .get
        }
        return try await fetchRaw(Account.self, req)
    }

    /// Get all accounts which follow the given account, if network is not hidden by the account owner.
    /// - Parameters
    ///     - id: the ID of the Account in the instance database.
    ///     - pageInfo: PagedInfo object for max/min/since
    ///     - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: the accounts requested, or an error if unable to retrieve
    public func getFollowers(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil)
        async throws -> PagedResult<[Account]>
    {
        let response = try await getFollowersRaw(for: id, pageInfo, limit: limit)
        return response.data
    }

    /// Get all accounts which follow the given account, if network is not hidden by the account owner, with HTTP response metadata
    /// - Parameters
    ///     - id: the ID of the Account in the instance database.
    ///     - pageInfo: PagedInfo object for max/min/since
    ///     - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: TootResponse containing the accounts requested and HTTP metadata
    public func getFollowersRaw(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil)
        async throws -> TootResponse<PagedResult<[Account]>>
    {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "followers"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResultRaw(req)
    }

    /// Get all accounts which the given account is following, if network is not hidden by the account owner.
    /// - Parameters:
    ///     - id: the ID of the Account in the instance database.
    ///     - pageInfo: PagedInfo object for max/min/since
    ///     - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: the accounts requested, or an error if unable to retrieve
    public func getFollowing(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil)
        async throws -> PagedResult<[Account]>
    {
        let response = try await getFollowingRaw(for: id, pageInfo, limit: limit)
        return response.data
    }

    /// Get all accounts which the given account is following, if network is not hidden by the account owner, with HTTP response metadata
    /// - Parameters:
    ///     - id: the ID of the Account in the instance database.
    ///     - pageInfo: PagedInfo object for max/min/since
    ///     - limit: Maximum number of results to return. Defaults to 40 accounts. Max 80 accounts.
    /// - Returns: TootResponse containing the accounts requested and HTTP metadata
    public func getFollowingRaw(for id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil)
        async throws -> TootResponse<PagedResult<[Account]>>
    {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "following"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResultRaw(req)
    }

    /// Attempts to register a user.
    ///
    /// Returns an account access token for the app that initiated the request. The app should save this token for later, and should wait for the user to confirm their account by clicking a link in their email inbox.
    public func registerAccount(params: RegisterAccountParams) async throws -> AccessToken {
        let response = try await registerAccountRaw(params: params)
        return response.data
    }

    /// Attempts to register a user with HTTP response metadata
    ///
    /// Returns TootResponse containing an account access token for the app that initiated the request and HTTP metadata. The app should save this token for later, and should wait for the user to confirm their account by clicking a link in their email inbox.
    public func registerAccountRaw(params: RegisterAccountParams) async throws -> TootResponse<AccessToken> {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }

        do {
            let (data, response) = try await fetch(req: req)
            let decodedData = try decode(AccessToken.self, from: data)
            
            // Convert HTTPURLResponse headers to [String: String]
            var headers: [String: String] = [:]
            for (key, value) in response.allHeaderFields {
                if let keyString = key as? String, let valueString = value as? String {
                    headers[keyString] = valueString
                }
            }
            
            return TootResponse(
                data: decodedData,
                headers: headers,
                statusCode: response.statusCode,
                url: response.url,
                rawBody: data
            )
        } catch {
            if case let TootSDKError.invalidStatusCode(data, _) = error {
                if let decoded = try? decode(RegisterAccountErrors.self, from: data),
                    let message = decoded.error
                {
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
        async throws -> [Account]
    {
        let response = try await searchAccountsRaw(params: params, limit: limit, offset: offset)
        return response.data
    }

    /// Search for matching accounts by username or display name with HTTP response metadata
    ///
    /// - Parameters:
    ///   - params: The search parameters.
    ///   - limit: Maximum number of results to return. Defaults to 40. Max 80 accounts.
    ///   - offset: Skip the first n results.
    /// - Returns: TootResponse containing search results and HTTP metadata.
    public func searchAccountsRaw(params: SearchAccountsParams, limit: Int? = nil, offset: Int? = nil)
        async throws -> TootResponse<[Account]>
    {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "search"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset) + params.queryItems
        }
        return try await fetchRaw([Account].self, req)
    }

    /// Retrieve lists in which the given account `id` is present
    public func getListsContainingAccount(id: String) async throws -> [List] {
        let response = try await getListsContainingAccountRaw(id: id)
        return response.data
    }

    /// Retrieve lists in which the given account `id` is present with HTTP response metadata
    /// - Returns: TootResponse containing lists in which the account is present and HTTP metadata
    public func getListsContainingAccountRaw(id: String) async throws -> TootResponse<[List]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id, "lists"])
            $0.method = .get
        }

        return try await fetchRaw([List].self, req)
    }

    /// Deletes the avatar associated with the user's profile.
    @discardableResult
    public func deleteProfileAvatar() async throws -> Account {
        let response = try await deleteProfileAvatarRaw()
        return response.data
    }

    /// Deletes the avatar associated with the user's profile with HTTP response metadata
    /// - Returns: TootResponse containing the updated account and HTTP metadata
    @discardableResult
    public func deleteProfileAvatarRaw() async throws -> TootResponse<Account> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "profile", "avatar"])
            $0.method = .delete
        }

        return try await fetchRaw(Account.self, req)
    }

    /// Deletes the header image associated with the user's profile.
    @discardableResult
    public func deleteProfileHeader() async throws -> Account {
        let response = try await deleteProfileHeaderRaw()
        return response.data
    }

    /// Deletes the header image associated with the user's profile with HTTP response metadata
    /// - Returns: TootResponse containing the updated account and HTTP metadata
    @discardableResult
    public func deleteProfileHeaderRaw() async throws -> TootResponse<Account> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "profile", "header"])
            $0.method = .delete
        }

        return try await fetchRaw(Account.self, req)
    }

    // TODO: - Lookup account ID from Webfinger address
}

extension TootFeature {

    /// Ability to edit your profile
    ///
    public static let updateCredentials = TootFeature(supportedFlavours: [
        .mastodon, .akkoma, .pleroma, .pixelfed, .firefish, .sharkey, .goToSocial, .catodon, .iceshrimp,
    ])
}
