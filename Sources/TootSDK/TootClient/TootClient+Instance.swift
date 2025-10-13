// Created by konstantin on 10/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension TootClient {
    /// Obtain general information about the server from the latest supported API version.
    ///
    /// If the server is known to be a flavour that supports the V2 Instance API, returns an ``InstanceV2``; otherwise, returns an ``InstanceV1``.
    ///
    /// If you require information that is only provided by a specific version of the Instance API, use ``getInstanceInfoV1()`` or ``getInstanceInfoV2()``.
    public func getInstanceInfo() async throws -> any Instance {
        let response = try await getInstanceInfoRaw()
        return response.data
    }

    /// Obtain general information about the server from the latest supported API version with HTTP response metadata
    ///
    /// If the server is known to be a flavour that supports the V2 Instance API, returns an ``InstanceV2``; otherwise, returns an ``InstanceV1``.
    /// - Returns: TootResponse containing the instance info and HTTP metadata
    public func getInstanceInfoRaw() async throws -> TootResponse<any Instance> {
        do {
            try requireFeature(.instanceV2)
            let response = try await getInstanceInfoV2Raw()
            return TootResponse(
                data: response.data as any Instance,
                headers: response.headers,
                statusCode: response.statusCode,
                url: response.url,
                rawBody: response.rawBody
            )
            // This function might be called before flavour is known, causing feature check to work incorrectly.
            // Attempt to fetch v1 instance info if call for v2 instance info fails with http error.
        } catch TootSDKError.unsupportedFlavour, TootSDKError.invalidStatusCode {
            let response = try await getInstanceInfoV1Raw()
            return TootResponse(
                data: response.data as any Instance,
                headers: response.headers,
                statusCode: response.statusCode,
                url: response.url,
                rawBody: response.rawBody
            )
        }
    }

    /// Obtain general information about the server from the V1 API.
    ///
    /// This API version was deprecated by Mastodon, but may be used by other instance flavours.
    public func getInstanceInfoV1() async throws -> InstanceV1 {
        let response = try await getInstanceInfoV1Raw()
        return response.data
    }

    /// Obtain general information about the server from the V1 API with HTTP response metadata
    ///
    /// This API version was deprecated by Mastodon, but may be used by other instance flavours.
    /// - Returns: TootResponse containing the instance info V1 and HTTP metadata
    public func getInstanceInfoV1Raw() async throws -> TootResponse<InstanceV1> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance"])
            $0.method = .get
        }
        return try await fetchRaw(InstanceV1.self, req)
    }

    /// Obtain general information about the server from the V2 API.
    ///
    /// > Important: Not all instance flavours support the V2 API; see ``TootFeature/instanceV2``. Consider checking for support using ``supportsFeature(_:)`` before calling this, otherwise it may fail.
    public func getInstanceInfoV2() async throws -> InstanceV2 {
        let response = try await getInstanceInfoV2Raw()
        return response.data
    }

    /// Obtain general information about the server from the V2 API with HTTP response metadata
    ///
    /// > Important: Not all instance flavours support the V2 API; see ``TootFeature/instanceV2``. Consider checking for support using ``supportsFeature(_:)`` before calling this, otherwise it may fail.
    /// - Returns: TootResponse containing the instance info V2 and HTTP metadata
    public func getInstanceInfoV2Raw() async throws -> TootResponse<InstanceV2> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "instance"])
            $0.method = .get
        }
        return try await fetchRaw(InstanceV2.self, req)
    }

    public func getInstanceRules() async throws -> [InstanceRule] {
        let response = try await getInstanceRulesRaw()
        return response.data
    }

    /// Get instance rules with HTTP response metadata
    /// - Returns: TootResponse containing the instance rules and HTTP metadata
    public func getInstanceRulesRaw() async throws -> TootResponse<[InstanceRule]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "rules"])
            $0.method = .get
        }
        return try await fetchRaw([InstanceRule].self, req)
    }

    /// Obtain an extended description of this server
    public func getExtendedDescription() async throws -> ExtendedDescription {
        let response = try await getExtendedDescriptionRaw()
        return response.data
    }

    /// Obtain an extended description of this server with HTTP response metadata
    /// - Returns: TootResponse containing the extended description and HTTP metadata
    public func getExtendedDescriptionRaw() async throws -> TootResponse<ExtendedDescription> {
        try requireFeature(.extendedDescription)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "extended_description"])
            $0.method = .get
        }
        return try await fetchRaw(ExtendedDescription.self, req)
    }

    /// Obtain the content of this server's privacy policy.
    /// - Returns: A ``PrivacyPolicy`` instance containing the content of the privacy policy.
    public func getPrivacyPolicy() async throws -> PrivacyPolicy {
        let response = try await getPrivacyPolicyRaw()
        return response.data
    }

    /// Obtain the content of this server's privacy policy with HTTP response metadata
    /// - Returns: TootResponse containing the privacy policy and HTTP metadata
    public func getPrivacyPolicyRaw() async throws -> TootResponse<PrivacyPolicy> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "privacy_policy"])
            $0.method = .get
        }
        return try await fetchRaw(PrivacyPolicy.self, req)
    }

    /// Obtain the content of this server's most current terms of service, if configured.
    /// - Returns: A ``TermsOfService`` instance representing the most recent effective terms of service, or the most recent version that exists if there is no currently effective version.
    ///
    /// Expected to return `404` if the instance has not configured its optional terms of service, even if it supports this endpoint.
    public func getTermsOfService() async throws -> TermsOfService {
        let response = try await getTermsOfServiceRaw()
        return response.data
    }

    /// Obtain the content of this server's most current terms of service with HTTP response metadata
    /// - Returns: TootResponse containing the terms of service and HTTP metadata
    ///
    /// Expected to return `404` if the instance has not configured its optional terms of service, even if it supports this endpoint.
    public func getTermsOfServiceRaw() async throws -> TootResponse<TermsOfService> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "terms_of_service"])
            $0.method = .get
        }
        return try await fetchRaw(TermsOfService.self, req)
    }

    /// Obtain a specific dated version of this server's terms of service.
    /// - Returns: A ``TermsOfService`` instance with the effective date specified by the `effectiveAsOf` parameter.
    ///
    /// Expected to return `404` if there is no terms of service with the exact effective date specified, or if the instance has not configured its optional terms of service.
    public func getTermsOfService(effectiveAsOf effectiveDate: Date) async throws -> TermsOfService {
        let response = try await getTermsOfServiceRaw(effectiveAsOf: effectiveDate)
        return response.data
    }

    /// Obtain a specific dated version of this server's terms of service with HTTP response metadata
    /// - Returns: TootResponse containing the terms of service and HTTP metadata
    ///
    /// Expected to return `404` if there is no terms of service with the exact effective date specified, or if the instance has not configured its optional terms of service.
    public func getTermsOfServiceRaw(effectiveAsOf effectiveDate: Date) async throws -> TootResponse<TermsOfService> {
        let encodedDate = TootEncoder.dateFormatterWithFullDate.string(from: effectiveDate)

        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "terms_of_service", encodedDate])
            $0.method = .get
        }
        return try await fetchRaw(TermsOfService.self, req)
    }

    /// Translation language pairs supported by the translation engine used by the server.
    public func getTranslationLanguages() async throws -> [String: [String]] {
        let response = try await getTranslationLanguagesRaw()
        return response.data
    }

    /// Translation language pairs supported by the translation engine used by the server with HTTP response metadata
    /// - Returns: TootResponse containing the translation languages and HTTP metadata
    public func getTranslationLanguagesRaw() async throws -> TootResponse<[String: [String]]> {
        try requireFeature(.translatePost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "translation_languages"])
            $0.method = .get
        }
        return try await fetchRaw([String: [String]].self, req)
    }

    /// Get the human-readable names of the instance's supported languages, localized to the instance's primary language.
    public func getLanguages() async throws -> [InstanceLanguage] {
        let response = try await getLanguagesRaw()
        return response.data
    }

    /// Get the human-readable names of the instance's supported languages with HTTP response metadata
    /// - Returns: TootResponse containing the instance languages and HTTP metadata
    public func getLanguagesRaw() async throws -> TootResponse<[InstanceLanguage]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "languages"])
            $0.method = .get
        }
        return try await fetchRaw([InstanceLanguage].self, req)
    }

    /// Get the list of domains that this instance is aware of.
    /// - Returns: Array of domains.
    ///
    /// Expected to return `401` if called without a user token if the instance is in limited federation mode.
    public func getPeers() async throws -> [String] {
        let response = try await getPeersRaw()
        return response.data
    }

    /// Get the list of domains that this instance is aware of with HTTP response metadata
    /// - Returns: TootResponse containing array of domains and HTTP metadata
    ///
    /// Expected to return `401` if called without a user token if the instance is in limited federation mode.
    public func getPeersRaw() async throws -> TootResponse<[String]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "peers"])
            $0.method = .get
        }
        return try await fetchRaw([String].self, req)
    }

    /// Obtain a list of domains that have been blocked.
    ///
    /// Expected to return `401` if the admin has chosen to require authorization and none is provided, or `404` if the admin has chosen to hide domain blocks entirely.
    public func getDomainBlocks() async throws -> [InstanceDomainBlock] {
        let response = try await getDomainBlocksRaw()
        return response.data
    }

    /// Obtain a list of domains that have been blocked with HTTP response metadata
    /// - Returns: TootResponse containing the domain blocks and HTTP metadata
    ///
    /// Expected to return `401` if the admin has chosen to require authorization and none is provided, or `404` if the admin has chosen to hide domain blocks entirely.
    public func getDomainBlocksRaw() async throws -> TootResponse<[InstanceDomainBlock]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "domain_blocks"])
            $0.method = .get
        }
        return try await fetchRaw([InstanceDomainBlock].self, req)
    }

    /// Get node info.
    public func getNodeInfo() async throws -> NodeInfo {
        let response = try await getNodeInfoRaw()
        return response.data
    }

    /// Get node info with HTTP response metadata
    /// - Returns: TootResponse containing the node info and HTTP metadata
    public func getNodeInfoRaw() async throws -> TootResponse<NodeInfo> {
        let wellKnownReq = HTTPRequestBuilder {
            $0.url = getURL([".well-known", "nodeinfo"])
            $0.method = .get
        }
        let wellKnown = try await fetch(WellKnownNodeInfo.self, wellKnownReq)
        guard let nodeInfo = wellKnown.nodeInfo else {
            throw TootSDKError.nodeInfoUnsupported
        }
        let req = HTTPRequestBuilder {
            $0.url = URL(string: nodeInfo)
            $0.method = .get
        }
        return try await fetchRaw(NodeInfo.self, req)
    }

    /// Get all custom emoji available on the server.
    /// - Returns: Array of ``Emoji``.
    public func getCustomEmojis() async throws -> [Emoji] {
        let response = try await getCustomEmojisRaw()
        return response.data
    }

    /// Get all custom emoji available on the server.
    /// - Returns: TootResponse containing an array of ``Emoji`` and HTTP metadata.
    public func getCustomEmojisRaw() async throws -> TootResponse<[Emoji]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "custom_emojis"])
            $0.method = .get
        }
        return try await fetchRaw([Emoji].self, req)
    }
}

extension TootFeature {

    /// Ability to retrieve instance extended descriptions
    ///
    public static let extendedDescription = TootFeature(supportedFlavours: [.mastodon])
}
