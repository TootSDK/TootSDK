// Created by konstantin on 02/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a profile field as a name-value pair with optional verification.
public struct TootField: Codable, Hashable {
    public init(name: String, value: String, verifiedAt: Date? = nil) {
        self.name = name
        self.value = value
        self.verifiedAt = verifiedAt
    }

    /// The key of a given field's key-value pair.
    public var name: String
    /// The value associated with the name key.
    public var value: String
    /// Timestamp of when the server verified a URL value for a rel="me” link.
    public var verifiedAt: Date?
}
