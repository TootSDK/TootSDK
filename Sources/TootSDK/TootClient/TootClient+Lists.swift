// Created by konstantin on 19/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public extension TootClient {

    /// Fetch all lists that the user owns.
    func getLists() async throws -> [List] {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists"])
            $0.method = .get
        }

        return try await fetch([List].self, req)
    }

    /// Fetch the list with the given ID. Used for verifying the title of a list, and which replies to show within that list.
    /// - Parameters:
    ///     - id: The ID of the List in the database.
    /// - Returns: the List, if successful, throws an error if not
    func getList(id: String) async throws -> List {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .get
        }

        return try await fetch(List.self, req)
    }

    /// Create a new list.
    /// - Returns: the List created, if successful, throws an error if not
    func createList(params: ListParams) async throws -> List {
        try requireFeature(.lists)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }

        return try await fetch(List.self, req)
    }

    /// Change the title of a list, or which replies to show.
    /// - Returns: the List created, if successful, throws an error if not
    func createList(id: String, params: ListParams) async throws -> List {
        try requireFeature(.lists)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .put
            $0.body = try .json(params, encoder: self.encoder)
        }

        return try await fetch(List.self, req)
    }

    /// Delete a list
    func deleteList(id: String) async throws {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }

    /// View accounts in a list
    /// - Returns: a PagedResult with an array of accounts if successful, throws an error if not
    func getListAccounts(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        try requireFeature(.lists)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
    }

    /// Add accounts to a list
    func addAccountsToList(id: String, params: AddAccountsToListParams) async throws {
        try requireFeature(.lists)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }

        _ = try await fetch(req: req)
    }

    /// Remove account from a list
    func removeAccountsFromList(id: String, params: RemoveAccountsFromListParams) async throws {
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
    /// - Warning: Not available for Pixelfed.
    public static let lists = TootFeature(supportedFlavours: [.mastodon, .pleroma, .friendica, .akkoma])
}
