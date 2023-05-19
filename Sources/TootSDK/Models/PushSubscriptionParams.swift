// Created by konstantin on 05/05/2023
// Copyright (c) 2023. All rights reserved.

import Foundation

/// Web Push API subscription request
public struct PushSubscriptionParams: Codable, Sendable {

    public var subscription: Subscription
    public var data: SubscriptionData?

    public struct Subscription: Codable, Sendable {
        public init(endpoint: String, keys: PushSubscriptionParams.Keys) {
            self.endpoint = endpoint
            self.keys = keys
        }

        /// The endpoint URL that is called when a notification event occurs.
        public var endpoint: String
        public var keys: PushSubscriptionParams.Keys
    }

    public struct Keys: Codable, Sendable {
        /// User agent public key. Base64 encoded string of a public key from a ECDH keypair using
        public var p256dh: String

        ///  Auth secret. Base64 encoded string of 16 bytes of random data.
        public var auth: String

        public init(p256dh: String, auth: String) {
            self.p256dh = p256dh
            self.auth = auth
        }
    }

    public struct SubscriptionData: Codable, Sendable {
        public var alerts: Alerts?
        /// Specify whether to receive push notifications from all, followed, follower, or none users.
        public var policy: String?

        public init(alerts: Alerts? = nil, policy: String? = nil) {
            self.alerts = alerts
            self.policy = policy
        }
    }

    public init(
        subscription: PushSubscriptionParams.Subscription,
        data: PushSubscriptionParams.SubscriptionData? = nil
    ) {
        self.subscription = subscription
        self.data = data
    }
}
