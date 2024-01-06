//
//  TootClient+Notifications.swift
//
//
//  Created by Konstantin on 04/05/2023.
//

import Foundation

extension TootClient {

    /// Get all notifications concerning the user
    ///  - Parameters:
    ///     -  limit: Maximum number of results to return. Defaults to 15 notifications. Max 30 notifications.
    public func getNotifications(params: TootNotificationParams = .init(), _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws
        -> PagedResult<[TootNotification]>
    {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications"])
            $0.method = .get
            $0.query = createQuery(from: params) + getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResult(req)
    }

    /// Get info about a single notification
    public func getNotification(id: String) async throws -> TootNotification {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", id])
            $0.method = .get
        }

        return try await fetch(TootNotification.self, req)
    }

    /// Clear all notifications from the server.
    public func dismissAllNotifications() async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", "clear"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }

    /// Dismiss a single notification from the server.
    public func dismissNotification(id: String) async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", id, "dismiss"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }

    /// Add a Web Push API subscription to receive notifications. Each access token can have one push subscription.
    ///
    /// If you create a new subscription, the old subscription is deleted.
    @discardableResult
    public func createPushSubscription(params: PushSubscriptionParams) async throws -> PushSubscription {
        try requireFeature(.pushSubscriptions)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .post
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        return try await fetch(PushSubscription.self, req)
    }

    /// View the PushSubscription currently associated with this access token.
    public func getPushSubscription() async throws -> PushSubscription {
        try requireFeature(.pushSubscriptions)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .get
        }

        return try await fetch(PushSubscription.self, req)
    }

    /// Updates the current push subscription. Only the data part can be updated.
    ///
    /// To change fundamentals, a new subscription must be created instead.
    public func changePushSubscription(params: PushSubscriptionUpdateParams) async throws -> PushSubscription {
        try requireFeature(.pushSubscriptions)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .put
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        return try await fetch(PushSubscription.self, req)
    }

    /// Removes the current Web Push API subscription.
    public func deletePushSubscription() async throws {
        try requireFeature(.pushSubscriptions)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .delete
        }
        _ = try await fetch(req: req)
    }
}

extension TootFeature {
    /// Ability to create Web Push API subscriptions to receive notifications.
    public static let pushSubscriptions = TootFeature(supportedFlavours: [.mastodon, .akkoma, .friendica, .pleroma])
}

extension TootClient {
    internal func createQuery(from params: TootNotificationParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()

        let params = params.corrected(for: flavour)

        if let types = params.types, !types.isEmpty {
            let name =
                switch flavour {
                case .pleroma, .akkoma: "include_types[]"
                default: "types[]"
                }
            queryParameters.append(contentsOf: types.map({ .init(name: name, value: $0.rawValue) }))
        }

        if let types = params.excludeTypes, !types.isEmpty {
            queryParameters.append(contentsOf: types.map({ .init(name: "exclude_types[]", value: $0.rawValue) }))
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

        if let alert = params.data?.alerts?.repost {
            queryParameters.append(.init(name: "data[alerts][reblog]", value: String(alert).lowercased()))
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
            queryParameters.append(.init(name: "data[policy]", value: policy.rawValue))
        }
        return queryParameters
    }

    internal func createQuery(from params: PushSubscriptionUpdateParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()

        if let alert = params.data.alerts?.mention {
            queryParameters.append(.init(name: "data[alerts][mention]", value: String(alert).lowercased()))
        }

        if let alert = params.data.alerts?.post {
            queryParameters.append(.init(name: "data[alerts][status]", value: String(alert).lowercased()))
        }

        if let alert = params.data.alerts?.follow {
            queryParameters.append(.init(name: "data[alerts][follow]", value: String(alert).lowercased()))
        }

        if let alert = params.data.alerts?.followRequest {
            queryParameters.append(.init(name: "data[alerts][follow_request]", value: String(alert).lowercased()))
        }

        if let alert = params.data.alerts?.favourite {
            queryParameters.append(.init(name: "data[alerts][favourite]", value: String(alert).lowercased()))
        }

        if let alert = params.data.alerts?.poll {
            queryParameters.append(.init(name: "data[alerts][poll]", value: String(alert).lowercased()))
        }

        if let alert = params.data.alerts?.update {
            queryParameters.append(.init(name: "data[alerts][update]", value: String(alert).lowercased()))
        }

        if let policy = params.data.policy {
            queryParameters.append(.init(name: "data[policy]", value: policy.rawValue))
        }
        return queryParameters
    }
}
