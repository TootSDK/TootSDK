// Created by konstantin on 19/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

extension TootClient {

    /// Fetch all lists that the user owns.
    public func getLists() async throws -> [List] {
        let response = try await getListsRaw()
        return response.data
    }

    /// Fetch all lists that the user owns with HTTP response metadata
    /// - Returns: TootResponse containing the lists and HTTP metadata
    public func getListsRaw() async throws -> TootResponse<[List]> {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists"])
            $0.method = .get
        }

        return try await fetchRaw([List].self, req)
    }

    /// Fetch the list with the given ID. Used for verifying the title of a list, and which replies to show within that list.
    /// - Parameters:
    ///     - id: The ID of the List in the database.
    /// - Returns: the List, if successful, throws an error if not
    public func getList(id: String) async throws -> List {
        let response = try await getListRaw(id: id)
        return response.data
    }

    /// Fetch the list with the given ID with HTTP response metadata
    /// - Parameters:
    ///     - id: The ID of the List in the database.
    /// - Returns: TootResponse containing the list and HTTP metadata
    public func getListRaw(id: String) async throws -> TootResponse<List> {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .get
        }

        return try await fetchRaw(List.self, req)
    }

    /// Create a new list.
    /// - Returns: the List created, if successful, throws an error if not
    public func createList(params: ListParams) async throws -> List {
        let response = try await createListRaw(params: params)
        return response.data
    }

    /// Create a new list with HTTP response metadata
    /// - Returns: TootResponse containing the created list and HTTP metadata
    public func createListRaw(params: ListParams) async throws -> TootResponse<List> {
        try requireFeature(.lists)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }

        return try await fetchRaw(List.self, req)
    }

    /// Change the title of a list, or which replies to show.
    /// - Returns: the List created, if successful, throws an error if not
    public func createList(id: String, params: ListParams) async throws -> List {
        let response = try await createListRaw(id: id, params: params)
        return response.data
    }

    /// Change the title of a list, or which replies to show with HTTP response metadata
    /// - Returns: TootResponse containing the updated list and HTTP metadata
    public func createListRaw(id: String, params: ListParams) async throws -> TootResponse<List> {
        try requireFeature(.lists)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .put
            $0.body = try .json(params, encoder: self.encoder)
        }

        return try await fetchRaw(List.self, req)
    }

    /// Delete a list
    public func deleteList(id: String) async throws {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

    /// View accounts in a list
    /// - Returns: a PagedResult with an array of accounts if successful, throws an error if not
    public func getListAccounts(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let response = try await getListAccountsRaw(id: id, pageInfo, limit: limit)
        return response.data
    }

    /// View accounts in a list with HTTP response metadata
    /// - Returns: TootResponse containing paginated accounts and HTTP metadata
    public func getListAccountsRaw(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> TootResponse<PagedResult<[Account]>> {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResultRaw(req)
    }

    /// Add accounts to a list
    public func addAccountsToList(id: String, params: AddAccountsToListParams) async throws {
        try requireFeature(.lists)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }

        _ = try await fetch(req: req)
    }

    /// Remove account from a list
    public func removeAccountsFromList(id: String, params: RemoveAccountsFromListParams) async throws {
        try requireFeature(.lists)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
            $0.method = .delete
            $0.body = try .json(params, encoder: self.encoder)
        }

        _ = try await fetch(req: req)
    }
}

extension TootFeature {

    /// Ability to create lists.
    ///
    public static let lists = TootFeature(supportedFlavours: [
        .mastodon, .pleroma, .friendica, .akkoma, .firefish, .sharkey, .goToSocial, .catodon, .iceshrimp,
    ])
}
