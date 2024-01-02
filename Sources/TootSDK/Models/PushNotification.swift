//
//  PushNotification.swift
//
//
//  Created by Łukasz Rutkowski on 30/12/2023.
//

import Foundation

/// Notification received via Web Push API.
public struct PushNotification: Codable {
    /// Access token used when subscribing to notifications.
    public let accessToken: String
    /// The notification body.
    public let body: String
    /// The notification title.
    public let title: String
    /// Avatar URL of user who caused the notification.
    public let icon: String
    /// The notification id.
    public let notificationId: Int
    /// The type of notification.
    public let notificationType: TootNotification.NotificationType
    /// The locale in which the user prefers to see notification.
    public let preferredLocale: String
}
