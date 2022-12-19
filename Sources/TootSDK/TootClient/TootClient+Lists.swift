// Created by konstantin on 19/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public extension TootClient {
    
    /// Fetch all lists that the user owns.
    func getLists() async throws -> [List] {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists"])
            $0.method = .get
        }
        
        return try await fetch([List].self, req) ?? []
    }
    
    /// Fetch the list with the given ID. Used for verifying the title of a list, and which replies to show within that list.
    /// - Parameters:
    ///     - id: The ID of the List in the database.
    ///
    func getList(id: String) async throws -> List? {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .get
        }
        
        return try await fetch(List.self, req)
    }
    
    /// Create a new list.
    func createList(params: ListParams) async throws -> List? {
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }
        
        return try await fetch(List.self, req)
    }
    
    /// Change the title of a list, or which replies to show.
    func createList(id: String, params: ListParams) async throws -> List? {
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .put
            $0.body = try .json(params, encoder: self.encoder)
        }
        
        return try await fetch(List.self, req)
    }
    
    /// Delete a list
    func deleteList(id: String) async throws {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id])
            $0.method = .delete
        }
        
        _ = try await fetch(req: req)
    }
    
    /// View accounts in a list
    func getListAccounts(id: String, _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[Account]> {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
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
    
    /// Add accounts to a list
    func addAccountsToList(id: String, params: AddAccountsToListParams) async throws {
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
            $0.method = .post
            $0.body = try .json(params, encoder: self.encoder)
        }
        
        _ = try await fetch(req: req)
    }
    
    /// Add accounts to a list
    func removeAccountsFromAList(id: String, params: RemoveAccountsFromListParams) async throws {
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "lists", id, "accounts"])
            $0.method = .delete
            $0.body = try .json(params, encoder: self.encoder)
        }
        
        _ = try await fetch(req: req)
    }
}
