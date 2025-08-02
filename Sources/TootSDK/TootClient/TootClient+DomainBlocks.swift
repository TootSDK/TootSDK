// Created by konstantin on 10/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension TootClient {

    /// Show information about all blocked domains.
    /// - Returns: array of blocked domains
    public func adminGetDomainBlocks() async throws -> [DomainBlock] {
        let response = try await adminGetDomainBlocksRaw()
        return response.data
    }

    /// Show information about all blocked domains with HTTP response metadata
    /// - Returns: TootResponse containing array of blocked domains and HTTP metadata
    public func adminGetDomainBlocksRaw() async throws -> TootResponse<[DomainBlock]> {
        try requireFeature(.adminDomainBlocks)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "admin", "domain_blocks"])
            $0.method = .get

        }

        return try await fetchRaw([DomainBlock].self, req)
    }

    /// Show information about a single blocked domain.
    /// - Parameter id: The ID of the DomainBlock in the instance's database
    /// - Returns: DomainBlock (optional)
    public func adminGetDomainBlock(id: String) async throws -> DomainBlock? {
        let response = try? await adminGetDomainBlockRaw(id: id)
        return response?.data
    }

    /// Show information about a single blocked domain with HTTP response metadata
    /// - Parameter id: The ID of the DomainBlock in the instance's database
    /// - Returns: TootResponse containing DomainBlock and HTTP metadata
    public func adminGetDomainBlockRaw(id: String) async throws -> TootResponse<DomainBlock> {
        try requireFeature(.adminDomainBlocks)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "admin", "domain_blocks", id])
            $0.method = .get
        }

        return try await fetchRaw(DomainBlock.self, req)
    }

    /// Blocks a domain on the current instance.
    /// * hide all public posts from it
    /// * hide all notifications from it
    /// * remove all followers from it
    /// * prevent following new users from it (but does not remove existing follows)
    ///
    /// Note that the call will be successful even if the domain is already blocked, or if the domain does not exist, or if the domain is not a domain.
    public func adminBlockDomain(params: BlockDomainParams) async throws -> DomainBlock {
        let response = try await adminBlockDomainRaw(params: params)
        return response.data
    }

    /// Blocks a domain on the current instance with HTTP response metadata
    /// * hide all public posts from it
    /// * hide all notifications from it
    /// * remove all followers from it
    /// * prevent following new users from it (but does not remove existing follows)
    ///
    /// Note that the call will be successful even if the domain is already blocked, or if the domain does not exist, or if the domain is not a domain.
    /// - Returns: TootResponse containing the blocked domain and HTTP metadata
    public func adminBlockDomainRaw(params: BlockDomainParams) async throws -> TootResponse<DomainBlock> {
        try requireFeature(.adminDomainBlocks)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "admin", "domain_blocks"])
            $0.method = .post
            $0.body = try .multipart(params, boundary: UUID().uuidString)
        }

        return try await fetchRaw(DomainBlock.self, req)
    }

    /// Lift a block against a domain.
    /// Note that the call will be successful even if the domain was not previously blocked.
    /// - Parameter domain: The ID of the DomainAllow in the database.
    public func adminUnblockDomain(domain: String) async throws {
        try requireFeature(.adminDomainBlocks)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "admin", "domain_blocks", domain])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }
}

extension TootClient {

    /// View domains the user has blocked.
    /// - Parameters:
    ///   - pageInfo: PagedInfo object for max/min/since ids
    ///   - limit: Maximum number of results to return. Defaults to 40.
    /// - Returns: Paginated response with an array of sttrings
    public func userGetDomainBlocks(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[String]> {
        let response = try await userGetDomainBlocksRaw(pageInfo, limit: limit)
        return response.data
    }

    /// View domains the user has blocked with HTTP response metadata
    /// - Parameters:
    ///   - pageInfo: PagedInfo object for max/min/since ids
    ///   - limit: Maximum number of results to return. Defaults to 40.
    /// - Returns: TootResponse containing paginated response with an array of strings and HTTP metadata
    public func userGetDomainBlocksRaw(_ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> TootResponse<PagedResult<[String]>> {
        try requireFeature(.domainBlocks)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "domain_blocks"])
            $0.method = .get
            $0.query = getQueryParams(pageInfo, limit: limit)
        }
        return try await fetchPagedResultRaw(req)
    }

    /// Blocks a domain on the current instance.
    /// * hide all public posts from it
    /// * hide all notifications from it
    /// * remove all followers from it
    /// * prevent following new users from it (but does not remove existing follows)
    ///
    /// Note that the call will be successful even if the domain is already blocked, or if the domain does not exist, or if the domain is not a domain.
    /// - Parameter domain: the domain to block (e.g "somewhere.social")
    public func userBlockDomain(domain: String) async throws {
        try requireFeature(.domainBlocks)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "domain_blocks"])
            $0.method = .post
            $0.body = try .multipart(BlockDomainParams(domain: domain), boundary: UUID().uuidString)
        }
        _ = try await fetch(req: req)
    }

    /// Remove a domain block, if it exists in the user’s array of blocked domains.
    /// Note that the call will be successful even if the domain was not previously blocked.
    /// - Parameter domain: the instance's id of the domain being unblocked
    public func userUnblockDomain(domain: String) async throws {
        try requireFeature(.domainBlocks)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "domain_blocks"])
            $0.method = .delete
            $0.body = try .multipart(BlockDomainParams(domain: domain), boundary: UUID().uuidString)
        }
        _ = try await fetch(req: req)
    }
}

extension TootFeature {

    /// Ability to block domains
    ///
    /// Not on Friendica
    public static let domainBlocks = TootFeature(supportedFlavours: [.mastodon, .akkoma, .pleroma, .pixelfed, .sharkey])

    /// Ability to block domains as an admin.
    public static let adminDomainBlocks = TootFeature(supportedFlavours: [.mastodon, .akkoma, .pleroma, .pixelfed, .sharkey, .goToSocial])
}
