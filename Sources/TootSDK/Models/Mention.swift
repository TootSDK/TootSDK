// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a mention of a user within the content of a status.
public struct Mention: Codable, Hashable {
    public init(id: String, username: String, url: String, acct: String) {
        self.id = id
        self.username = username
        self.url = url
        self.acct = acct
    }

    /// The account id of the mentioned user.
    public var id: String
    /// The username of the mentioned user.
    public var username: String
    /// The location of the mentioned user's profile.
    public var url: String
    /// The webfinger acct: URI of the mentioned user.
    /// Equivalent to username for local users, or username@domain for remote users.
    public var acct: String
}
