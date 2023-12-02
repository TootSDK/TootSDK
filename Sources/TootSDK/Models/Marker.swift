// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents the last read position within a user's timelines.
public struct Marker: Codable, Hashable {
    public init(lastReadId: String, updatedAt: Date, version: Int) {
        self.lastReadId = lastReadId
        self.updatedAt = updatedAt
        self.version = version
    }

    /// The ID of the most recently viewed entity.
    public var lastReadId: String
    /// The timestamp of when the marker was set.
    public var updatedAt: Date
    /// Used for locking to prevent write conflicts.
    public var version: Int

    /// Identifies a timeline for which a position can be saved.
    public enum Timeline: String, Hashable, Codable, CodingKeyRepresentable {
        /// Information about the user's position in the home timeline.
        case home
        /// Information about the user's position in their notifications.
        case notifications
    }
}
