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
        let response = try await getNotificationsRaw(params: params, pageInfo, limit: limit)
        return response.data
    }

    /// Get all notifications concerning the user with HTTP response metadata
    ///  - Parameters:
    ///     -  limit: Maximum number of results to return. Defaults to 15 notifications. Max 30 notifications.
    /// - Returns: TootResponse containing paginated notifications and HTTP metadata
    public func getNotificationsRaw(params: TootNotificationParams = .init(), _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws
        -> TootResponse<PagedResult<[TootNotification]>>
    {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications"])
            $0.method = .get
            $0.query = createQuery(from: params) + getQueryParams(pageInfo, limit: limit)
        }

        return try await fetchPagedResultRaw(req)
    }

    /// Get info about a single notification
    public func getNotification(id: String) async throws -> TootNotification {
        let response = try await getNotificationRaw(id: id)
        return response.data
    }

    /// Get info about a single notification with HTTP response metadata
    /// - Returns: TootResponse containing the notification and HTTP metadata
    public func getNotificationRaw(id: String) async throws -> TootResponse<TootNotification> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", id])
            $0.method = .get
        }

        return try await fetchRaw(TootNotification.self, req)
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
        try requireFeature(.dismissNotification)
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
        let response = try await createPushSubscriptionRaw(params: params)
        return response.data
    }

    /// Add a Web Push API subscription to receive notifications with HTTP response metadata
    ///
    /// If you create a new subscription, the old subscription is deleted.
    /// - Returns: TootResponse containing the push subscription and HTTP metadata
    @discardableResult
    public func createPushSubscriptionRaw(params: PushSubscriptionParams) async throws -> TootResponse<PushSubscription> {
        try requireFeature(.pushSubscriptions)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .post
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        return try await fetchRaw(PushSubscription.self, req)
    }

    /// View the PushSubscription currently associated with this access token.
    public func getPushSubscription() async throws -> PushSubscription {
        let response = try await getPushSubscriptionRaw()
        return response.data
    }

    /// View the PushSubscription currently associated with this access token with HTTP response metadata
    /// - Returns: TootResponse containing the push subscription and HTTP metadata
    public func getPushSubscriptionRaw() async throws -> TootResponse<PushSubscription> {
        try requireFeature(.pushSubscriptions)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .get
        }

        return try await fetchRaw(PushSubscription.self, req)
    }

    /// Updates the current push subscription. Only the data part can be updated.
    ///
    /// To change fundamentals, a new subscription must be created instead.
    public func changePushSubscription(params: PushSubscriptionUpdateParams) async throws -> PushSubscription {
        let response = try await changePushSubscriptionRaw(params: params)
        return response.data
    }

    /// Updates the current push subscription with HTTP response metadata
    ///
    /// To change fundamentals, a new subscription must be created instead.
    /// - Returns: TootResponse containing the updated push subscription and HTTP metadata
    public func changePushSubscriptionRaw(params: PushSubscriptionUpdateParams) async throws -> TootResponse<PushSubscription> {
        try requireFeature(.pushSubscriptions)
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "push", "subscription"])
            $0.method = .put
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        return try await fetchRaw(PushSubscription.self, req)
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
    public static let pushSubscriptions = TootFeature(supportedFlavours: [.mastodon, .akkoma, .friendica, .pleroma, .goToSocial])

    /// Ability to specify policy for push notifications.
    public static let pushSubscriptionsPolicy = TootFeature(supportedFlavours: [.mastodon, .goToSocial])

    /// Ability to specify whether to use standardized webpush (RFC8030+RFC8291+RFC8292) or legacy webpush (unpublished version, 4th draft of RFC8291 and 1st draft of RFC8292).
    public static let pushSubscriptionsStandard = TootFeature(requirements: [.from(.mastodon, displayVersion: "4.4.0")])
}

extension TootClient {
    internal func createQuery(from params: TootNotificationParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()

        let params = params.corrected(for: flavour)

        if let types = params.types, !types.isEmpty {
            let name: String
            switch flavour {
            case .pleroma, .akkoma: name = "include_types[]"
            default: name = "types[]"
            }
            queryParameters.append(contentsOf: types.map({ .init(name: name, value: $0.rawValue(flavour: flavour)) }))
        }

        if let types = params.excludeTypes, !types.isEmpty {
            queryParameters.append(contentsOf: types.map({ .init(name: "exclude_types[]", value: $0.rawValue(flavour: flavour)) }))
        }

        return queryParameters
    }

    internal func createQuery(from params: PushSubscriptionParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()
        queryParameters.append(.init(name: "subscription[endpoint]", value: params.subscription.endpoint))
        queryParameters.append(.init(name: "subscription[keys][p256dh]", value: params.subscription.keys.p256dh))
        queryParameters.append(.init(name: "subscription[keys][auth]", value: params.subscription.keys.auth))
        if let standard = params.subscription.standard {
            queryParameters.append(.init(name: "subscription[standard]", value: String(standard).lowercased()))
        }
        queryParameters.append(contentsOf: createQuery(from: params.data))
        return queryParameters
    }

    internal func createQuery(from params: PushSubscriptionUpdateParams) -> [URLQueryItem] {
        return createQuery(from: params.data)
    }

    internal func createQuery(from data: PushSubscriptionParams.SubscriptionData?) -> [URLQueryItem] {
        var queryParameters: [URLQueryItem] = []
        if let alert = data?.alerts?.mention {
            queryParameters.append(.init(name: "data[alerts][mention]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.post {
            queryParameters.append(.init(name: "data[alerts][status]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.repost {
            queryParameters.append(.init(name: "data[alerts][reblog]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.follow {
            queryParameters.append(.init(name: "data[alerts][follow]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.followRequest {
            queryParameters.append(.init(name: "data[alerts][follow_request]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.favourite {
            queryParameters.append(.init(name: "data[alerts][favourite]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.poll {
            queryParameters.append(.init(name: "data[alerts][poll]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.update {
            queryParameters.append(.init(name: "data[alerts][update]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.adminSignUp {
            queryParameters.append(.init(name: "data[alerts][admin.sign_up]", value: String(alert).lowercased()))
        }

        if let alert = data?.alerts?.adminReport {
            queryParameters.append(.init(name: "data[alerts][admin.report]", value: String(alert).lowercased()))
        }

        if let policy = data?.policy {
            queryParameters.append(.init(name: "data[policy]", value: policy.rawValue))
        }
        return queryParameters
    }
}

extension TootFeature {

    /// Ability to dismiss (or mark as read) a single notification
    ///
    public static let dismissNotification = TootFeature(supportedFlavours: [
        .mastodon, .akkoma, .pleroma, .pixelfed, .friendica, .firefish, .catodon, .iceshrimp,
    ])
}
