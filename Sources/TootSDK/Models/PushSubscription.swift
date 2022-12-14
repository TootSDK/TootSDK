// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a subscription to the push streaming server.
public struct PushSubscription: Codable {
    public init(id: String, endpoint: String, alerts: PushSubscription.Alerts, serverKey: String) {
        self.id = id
        self.endpoint = endpoint
        self.alerts = alerts
        self.serverKey = serverKey
    }

    public struct Alerts: Codable, Hashable {
        /// Receive a push notification when someone has followed you? Boolean.
        public var follow: Bool
        /// Receive a push notification when a status you created has been favourited by someone else? Boolean.
        public var favourite: Bool
        /// Receive a push notification when a status you created has been boosted by someone else? Boolean.
        public var reblog: Bool
        /// Receive a push notification when someone else has mentioned you in a status? Boolean.
        public var mention: Bool
        /// Receive a push notification when a poll you voted in or created has ended? Boolean. Added in 2.8.0
        public var poll: Bool?
        public var followRequest: Bool?
        public var status: Bool?
    }

    /// The id of the push subscription in the database.
    public var id: String
    /// Where push alerts will be sent to.
    public var endpoint: String
    /// Which alerts should be delivered to the endpoint.
    public var alerts: Alerts
    /// The streaming server's VAPID key.
    public var serverKey: String
}
