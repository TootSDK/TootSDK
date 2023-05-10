//
//  TootClient+Notifications.swift
//
//
//  Created by Konstantin on 04/05/2023.
//

import Foundation

public extension TootClient {

    /// Get all notifications concerning the user
    func getNotifications(params: TootNotificationParams = .init(), _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[TootNotification]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications"])
            $0.method = .get
            $0.query = createQuery(from: params) + getQueryParams(pageInfo, limit: limit)
        }
        
        return try await fetchPagedResult(req, pageInfo, limit: limit)
    }

    /// Get info about a single notification
    func getNotification(id: String) async throws -> TootNotification {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", id])
            $0.method = .get
        }

        return try await fetch(TootNotification.self, req)
    }

    /// Clear all notifications from the server.
    func dismissAllNotifications() async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", "clear"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }

    /// Dismiss a single notification from the server.
    func dismissNotification(id: String) async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", id, "dismiss"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }

    /// Add a Web Push API subscription to receive notifications. Each access token can have one push subscription.
    ///
    /// If you create a new subscription, the old subscription is deleted.
    func createPushSubscription(params: PushSubscriptionParams) async throws -> PushSubscription {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .post
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        return try await fetch(PushSubscription.self, req)
    }

    /// View the PushSubscription currently associated with this access token.
    func getPushSubscription() async throws -> PushSubscription {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .get
        }

        return try await fetch(PushSubscription.self, req)
    }

    /// Updates the current push subscription. Only the data part can be updated.
    ///
    /// To change fundamentals, a new subscription must be created instead.
    func changePushSubscription(params: PushSubscriptionUpdateParams) async throws -> PushSubscription {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .put
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        return try await fetch(PushSubscription.self, req)
    }

    internal func createQuery(from params: TootNotificationParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()

        if let types = params.types, !types.isEmpty {
            queryParameters.append(contentsOf: types.map({.init(name: "types[]", value: $0.rawValue)}))
        }

        if let types = params.excludeTypes, !types.isEmpty {
            queryParameters.append(contentsOf: types.map({.init(name: "exclude_types[]", value: $0.rawValue)}))
        }

        return queryParameters
    }

    internal func createQuery(from params: PushSubscriptionParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()
        queryParameters.append(.init(name: "subscription[endpoint]", value: params.subscription.endpoint))
        queryParameters.append(.init(name: "subscription[keys][p256dh]", value: params.subscription.keys.p256dh))
        queryParameters.append(.init(name: "subscription[keys][auth]", value: params.subscription.keys.auth))

        if let alert = params.data?.alerts?.mention {
            queryParameters.append(.init(name: "data[alerts][mention]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.post {
            queryParameters.append(.init(name: "data[alerts][status]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.follow {
            queryParameters.append(.init(name: "data[alerts][follow]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.followRequest {
            queryParameters.append(.init(name: "data[alerts][follow_request]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.favourite {
            queryParameters.append(.init(name: "data[alerts][favourite]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.poll {
            queryParameters.append(.init(name: "data[alerts][poll]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.update {
            queryParameters.append(.init(name: "data[alerts][update]", value: String(alert).lowercased()))
        }

        if let policy = params.data?.policy {
            queryParameters.append(.init(name: "data[policy]", value: policy))
        }
        return queryParameters
    }

    internal func createQuery(from params: PushSubscriptionUpdateParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()

        if let alert = params.data?.alerts?.mention {
            queryParameters.append(.init(name: "data[alerts][mention]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.post {
            queryParameters.append(.init(name: "data[alerts][status]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.follow {
            queryParameters.append(.init(name: "data[alerts][follow]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.followRequest {
            queryParameters.append(.init(name: "data[alerts][follow_request]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.favourite {
            queryParameters.append(.init(name: "data[alerts][favourite]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.poll {
            queryParameters.append(.init(name: "data[alerts][poll]", value: String(alert).lowercased()))
        }

        if let alert = params.data?.alerts?.update {
            queryParameters.append(.init(name: "data[alerts][update]", value: String(alert).lowercased()))
        }

        if let policy = params.data?.policy {
            queryParameters.append(.init(name: "data[policy]", value: policy))
        }
        return queryParameters
    }
}
