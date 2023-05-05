//
//  File.swift
//
//
//  Created by Konstantin on 04/05/2023.
//

import Foundation

public struct TootNotificationParams: Codable, Sendable {
    public init(excludeTypes: [TootNotification.NotificationType]? = nil, types: [TootNotification.NotificationType]? = nil) {
        self.excludeTypes = excludeTypes
        self.types = types
    }

    public init() {
        self.excludeTypes = nil
        self.types = nil
    }

    /// Types of notifications to exclude from the search results
    public var excludeTypes: [TootNotification.NotificationType]?
    /// Types of notifications to include in the search results
    public var types: [TootNotification.NotificationType]?

    enum CodingKeys: String, CodingKey {
        case excludeTypes = "exclude_types"
        case types = "types"
    }
}
