//
//  PushNotification.swift
//
//
//  Created by Łukasz Rutkowski on 30/12/2023.
//

import Foundation

public struct PushNotification: Codable {
    public let accessToken: String
    public let body: String
    public let title: String
    public let icon: String
    public let notificationId: Int
    public let notificationType: TootNotification.NotificationType
    public let preferredLocale: String
}
