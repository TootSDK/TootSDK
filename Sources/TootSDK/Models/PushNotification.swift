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
    public let notificationId: String
    /// The type of notification.
    public let notificationType: TootNotification.NotificationType
    /// The locale in which the user prefers to see notification.
    public let preferredLocale: String

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.body = try container.decode(String.self, forKey: .body)
        self.title = try container.decode(String.self, forKey: .title)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.notificationId = try container.decodeIntOrString(forKey: .notificationId)
        self.notificationType = try container.decode(TootNotification.NotificationType.self, forKey: .notificationType)
        self.preferredLocale = try container.decode(String.self, forKey: .preferredLocale)
    }
}
