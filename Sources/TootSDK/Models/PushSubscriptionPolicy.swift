//
//  PushSubscriptionPolicy.swift
//  
//
//  Created by Łukasz Rutkowski on 06/01/2024.
//

import Foundation

/// Decides from who to receive push notifications.
public enum PushSubscriptionPolicy: String, Codable, Hashable, Sendable {
    /// Allow push notifications from everyone.
    case all
    /// Allow push notifications only from followed users.
    case followed
    /// Allow push notifications only from followers.
    case follower
    /// Disallow all push notifications.
    case disabled = "none"
}
