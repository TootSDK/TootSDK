//
//  TootClient+Directory.swift
//
//
//  Created by Philip Chu on 5/29/23.
//

import Foundation

extension TootClient {

    /// List accounts visible in the directory.
    ///
    /// - Parameters:
    ///   - offset. Skip the first n results.
    ///   - limit: How many accounts to load. Defaults to 40 accounts. Max 80 accounts.
    ///   - params: Includes order and local parameters.
    /// - Returns: Array of ``Account``.
    public func getProfileDirectory(params: ProfileDirectoryParams, offset: Int? = nil, limit: Int? = nil) async throws -> [Account] {
        let response = try await getProfileDirectoryRaw(params: params, offset: offset, limit: limit)
        return response.data
    }

    /// List accounts visible in the directory with HTTP response metadata
    ///
    /// - Parameters:
    ///   - offset. Skip the first n results.
    ///   - limit: How many accounts to load. Defaults to 40 accounts. Max 80 accounts.
    ///   - params: Includes order and local parameters.
    /// - Returns: TootResponse containing array of Accounts and HTTP metadata
    public func getProfileDirectoryRaw(params: ProfileDirectoryParams, offset: Int? = nil, limit: Int? = nil) async throws -> TootResponse<[Account]> {
        try requireFeature(.profileDirectory)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "directory"])
            $0.method = .get
            $0.query = getQueryParams(limit: limit, offset: offset) + params.queryItems
        }

        return try await fetchRaw([Account].self, req)
    }
}

extension TootFeature {

    /// Ability to query profile directories
    ///
    public static let profileDirectory = TootFeature(supportedFlavours: [.mastodon, .akkoma, .pleroma, .friendica])
}
