// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents the results of a search.
public struct Results: Codable {
    public init(accounts: [Account], statuses: [Status], hashtags: [Tag]) {
        self.accounts = accounts
        self.statuses = statuses
        self.hashtags = hashtags
    }

    /// Accounts which match the given query
    public var accounts: [Account]
    /// Statuses which match the given query
    public var statuses: [Status]
    /// Hashtags which match the given query
    public var hashtags: [Tag]
}
