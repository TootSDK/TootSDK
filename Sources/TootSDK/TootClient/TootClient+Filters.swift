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
        let response = try await getFiltersRaw()
        return response.data
    }

    /// Obtain a list of all filter groups for the current user with HTTP response metadata
    ///
    /// - Returns: TootResponse containing the filters and HTTP metadata
    public func getFiltersRaw() async throws -> TootResponse<[Filter]> {
        try requireFeature(.filtersV2)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters"])
            $0.method = .get
        }
        return try await fetchRaw([Filter].self, req)
    }

    /// Obtain a single filter group owned by the current user.
    ///
    /// - Parameters:
    ///   - id: The ID of the Filter in the database.
    /// - Returns: the Filter, if successful, throws an error if not
    public func getFilter(id: String) async throws -> Filter {
        let response = try await getFilterRaw(id: id)
        return response.data
    }

    /// Obtain a single filter group owned by the current user with HTTP response metadata
    ///
    /// - Parameters:
    ///   - id: The ID of the Filter in the database.
    /// - Returns: TootResponse containing the Filter and HTTP metadata
    public func getFilterRaw(id: String) async throws -> TootResponse<Filter> {
        try requireFeature(.filtersV2)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters", id])
            $0.method = .get
        }
        return try await fetchRaw(Filter.self, req)
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
        let response = try await createFilterRaw(params)
        return response.data
    }

    /// Create a filter with HTTP response metadata
    ///
    /// - Parameter params: Parameters of filter to create.
    /// - Returns: TootResponse containing the created filter and HTTP metadata
    @discardableResult
    public func createFilterRaw(_ params: CreateFilterParams) async throws -> TootResponse<Filter> {
        try requireFeature(.filtersV2)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters"])
            $0.method = .post
            $0.body = try .form(queryItems: params.queryItems)
        }
        return try await fetchRaw(Filter.self, req)
    }

    /// Update a filter.
    ///
    /// - Parameter params: Parameters of filter update.
    /// - Returns: The updated filter.
    @discardableResult
    public func updateFilter(_ params: UpdateFilterParams) async throws -> Filter {
        let response = try await updateFilterRaw(params)
        return response.data
    }

    /// Update a filter with HTTP response metadata
    ///
    /// - Parameter params: Parameters of filter update.
    /// - Returns: TootResponse containing the updated filter and HTTP metadata
    @discardableResult
    public func updateFilterRaw(_ params: UpdateFilterParams) async throws -> TootResponse<Filter> {
        try requireFeature(.filtersV2)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "filters", params.id])
            $0.method = .put
            $0.body = try .form(queryItems: params.queryItems)
        }
        return try await fetchRaw(Filter.self, req)
    }
}

extension TootFeature {

    /// Ability to  view/edit/create filters.
    ///
    public static let filtersV2 = TootFeature(supportedFlavours: [.mastodon, .goToSocial])

    /// Ability to use `blur` value on `filter_action` attribute of filters.
    public static let filterBlurAction = TootFeature(requirements: [
        .from(.mastodon, version: 5)
    ])
}
