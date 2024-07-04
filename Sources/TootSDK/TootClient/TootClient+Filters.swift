//
//  TootClient+Filters.swift
//
//
//  Created by Philip Chu on 7/20/23.
//

import Foundation

extension TootClient {

    /// Obtain a list of all filter groups for the current user.
    ///
    /// - Returns: The filters or an error if unable to retrieve.
    public func getFilters() async throws -> [Filter] {
        try requireFeature(.filtersV2)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters"])
            $0.method = .get
        }
        return try await fetch([Filter].self, req)
    }

    /// Obtain a single filter group owned by the current user.
    ///
    /// - Parameters:
    ///   - id: The ID of the Filter in the database.
    /// - Returns: the Filter, if successful, throws an error if not
    public func getFilter(id: String) async throws -> Filter {
        try requireFeature(.filtersV2)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters", id])
            $0.method = .get
        }
        return try await fetch(Filter.self, req)
    }

    /// Delete a filter
    ///
    /// - Parameters:
    ///   - id: The ID of the Filter in the database.
    public func deleteFilter(id: String) async throws {
        try requireFeature(.filtersV2)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters", id])
            $0.method = .delete
        }
        _ = try await fetch(req: req)
    }

    /// Create a filter.
    ///
    /// - Parameter params: Parameters of filter to create.
    /// - Returns: The created filter.
    @discardableResult
    public func createFilter(_ params: CreateFilterParams) async throws -> Filter {
        try requireFeature(.filtersV2)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters"])
            $0.method = .post
            $0.body = try .form(queryItems: params.queryItems)
        }
        return try await fetch(Filter.self, req)
    }

    /// Update a filter.
    ///
    /// - Parameter params: Parameters of filter update.
    /// - Returns: The updated filter.
    @discardableResult
    public func updateFilter(_ params: UpdateFilterParams) async throws -> Filter {
        try requireFeature(.filtersV2)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters", params.id])
            $0.method = .put
            $0.body = try .form(queryItems: params.queryItems)
        }
        return try await fetch(Filter.self, req)
    }
}

extension TootFeature {

    /// Ability to  view/edit/create filters.
    ///
    public static let filtersV2 = TootFeature(supportedFlavours: [.mastodon])
}
