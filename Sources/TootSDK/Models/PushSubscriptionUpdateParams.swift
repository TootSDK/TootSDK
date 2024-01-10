// Created by konstantin on 05/05/2023
// Copyright (c) 2023. All rights reserved.

import Foundation

/// Change Web Push API subscription configuration request
public struct PushSubscriptionUpdateParams: Codable, Sendable {
    public var data: SubscriptionData

    public init(data: SubscriptionData) {
        self.data = data
    }

    public typealias SubscriptionData = PushSubscriptionParams.SubscriptionData
}
