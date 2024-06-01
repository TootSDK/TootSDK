// Created by konstantin on 18/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension TootClient {

    internal func getURL(_ components: [String]) -> URL {
        var url = instanceURL
        for component in components {
            url.appendPathComponent(component)
        }
        return url
    }

    internal func getURL(base: URL, appendingComponents components: [String]) -> URL {
        var url = base
        for component in components {
            url.appendPathComponent(component)
        }
        return url
    }

    internal func getQueryParams(
        _ pageInfo: PagedInfo? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        query: (any TimelineQuery)? = nil
    ) -> [URLQueryItem] {

        var queryParameters = [URLQueryItem]()

        if let maxId = pageInfo?.maxId {
            queryParameters.append(.init(name: "max_id", value: maxId))
        }

        if let minId = pageInfo?.minId {
            queryParameters.append(.init(name: "min_id", value: minId))
        }

        if let sinceId = pageInfo?.sinceId {
            queryParameters.append(.init(name: "since_id", value: sinceId))
        }

        if let limit {
            queryParameters.append(.init(name: "limit", value: String(limit)))
        }

        if let offset {
            queryParameters.append(.init(name: "offset", value: String(offset)))
        }

        if let query {
            queryParameters += query.getQueryItems()
        }

        return queryParameters
    }

    internal func getAuthorizationInfo(
        callbackURI: String,
        scopes: [String],
        website: String = "",
        responseType: String = "code"
    ) async throws -> CallbackInfo {

        let createAppData = CreateAppRequest(
            clientName: clientName,
            redirectUris: callbackURI,
            scopes: scopes.joined(separator: " "), website: website)

        let registerAppReq = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "apps"])
            $0.method = .post
            $0.body = try .json(createAppData, encoder: self.encoder)
        }

        let app = try await fetch(TootApplication.self, registerAppReq)

        guard let clientId = app.clientId else {
            throw TootSDKError.clientAuthorizationFailed
        }

        let signUrlReq = HTTPRequestBuilder {
            $0.url = getURL(["oauth", "authorize"])
            $0.addQueryParameter(name: "client_id", value: clientId)
            $0.addQueryParameter(name: "redirect_uri", value: callbackURI)
            $0.addQueryParameter(name: "scope", value: scopes.joined(separator: " "))
            $0.addQueryParameter(name: "response_type", value: responseType)
        }

        guard let url = signUrlReq.url else {
            throw TootSDKError.unexpectedError("Failed to create authorize url")
        }

        return .init(url: url, application: app)
    }

    internal func getAccessToken(
        code: String?, clientId: String, clientSecret: String, callbackURI: String, grantType: String = "authorization_code",
        scopes: [String] = ["read", "write", "follow", "push"]
    ) async throws -> AccessToken {

        let queryItems: [URLQueryItem] = [
            .init(name: "client_id", value: clientId),
            .init(name: "client_secret", value: clientSecret),
            .init(name: "grant_type", value: grantType),
            .init(name: "scope", value: scopes.joined(separator: " ")),
            .init(name: "code", value: code),
            .init(name: "redirect_uri", value: callbackURI),
        ]

        let req = try HTTPRequestBuilder {
            $0.url = getURL(["oauth", "token"])
            $0.method = .post
            $0.body = try .form(queryItems: queryItems)
        }

        return try await fetch(AccessToken.self, req)
    }
}
