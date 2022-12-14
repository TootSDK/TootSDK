// Created by konstantin on 05/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents daily usage history of a hashtag.
public struct TagHistory: Codable, Hashable {
    public init(day: String,
                uses: String,
                accounts: String) {
        self.day = day
        self.uses = uses
        self.accounts = accounts
    }

    /// UNIX timestamp on midnight of the given day.
    public let day: String
    /// the counted usage of the tag within that day.
    public let uses: String
    /// the total of accounts using the tag within that day.
    public let accounts: String
}
