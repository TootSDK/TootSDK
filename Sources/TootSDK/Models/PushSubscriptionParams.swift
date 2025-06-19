// Created by konstantin on 05/05/2023
// Copyright (c) 2023. All rights reserved.

import Crypto
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

    /// Encryption related data of push subscription.
    public struct Keys: Codable, Sendable {
        /// User agent public key. Base64 URL safe encoded string of a public key from a ECDH keypair using
        public var p256dh: String

        /// Auth secret. Base64 URL safe encoded string of 16 bytes of random data.
        public var auth: String

        /// Initializes encryption related data of push subscription.
        ///
        /// - Parameters:
        ///   - p256dh: User agent public key. Base64 URL safe encoded string of a public key from a ECDH keypair using
        ///   - auth: Auth secret. Base64 URL safe encoded string of 16 bytes of random data.
        public init(p256dh: String, auth: String) {
            self.p256dh = p256dh
            self.auth = auth
        }

        /// Initializes encryption related data of push subscription.
        ///
        /// - Parameters:
        ///   - p256dh: User agent public key.
        ///   - auth: Auth secret as 16 bytes of random data.
        public init(p256dh: P256.KeyAgreement.PublicKey, auth: Data) {
            self.p256dh = p256dh.x963Representation.urlSafeBase64EncodedString()
            self.auth = auth.urlSafeBase64EncodedString()
        }

        /// Initializes encryption related data of push subscription.
        public init(_ keys: WebPushMessageEncryption.Keys) {
            self.init(
                p256dh: keys.publicKey,
                auth: keys.auth
            )
        }
    }

    public struct SubscriptionData: Codable, Sendable {
        /// Specify which alerts should be received.
        public var alerts: Alerts?
        /// Specify whether to receive push notifications from all, followed, follower, or none users.
        public var policy: OpenEnum<PushSubscriptionPolicy>?

        public init(alerts: Alerts? = nil, policy: PushSubscriptionPolicy? = nil) {
            self.alerts = alerts
            self.policy = .optional(policy)
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
