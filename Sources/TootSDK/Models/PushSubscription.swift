// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a subscription to the push streaming server.
public struct PushSubscription: Codable, Sendable {
    public init(endpoint: String, alerts: Alerts, serverKey: String, policy: PushSubscriptionPolicy?) {
        self.endpoint = endpoint
        self.alerts = alerts
        self.serverKey = serverKey
        self.policy = policy
    }

    /// Where push alerts will be sent to.
    public var endpoint: String
    /// Which alerts should be delivered to the endpoint.
    public var alerts: Alerts
    /// The streaming server's VAPID key.
    public var serverKey: String
    /// From who to receive push notifications.
    public var policy: PushSubscriptionPolicy?
}
