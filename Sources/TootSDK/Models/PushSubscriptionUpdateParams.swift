// Created by konstantin on 05/05/2023
// Copyright (c) 2023. All rights reserved.

import Foundation

/// Change Web Push API subscription configuration request
public struct PushSubscriptionUpdateParams: Codable, Sendable {
    public var data: SubscriptionData?
    public struct SubscriptionData: Codable, Sendable {
        public var alerts: Alerts?
        /// Specify whether to receive push notifications from all, followed, follower, or none users.
        public var policy: String?
    }

    public init(data: PushSubscriptionUpdateParams.SubscriptionData? = nil) {
        self.data = data
    }
}
