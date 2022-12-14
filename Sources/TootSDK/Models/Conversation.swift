// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Conversation: Codable, Hashable {
    public var id: String
    public var accounts: [Account]
    public var unread: Bool
    public var lastStatus: Status?

    public init(id: String, accounts: [Account], unread: Bool, lastStatus: Status?) {
        self.id = id
        self.accounts = accounts
        self.unread = unread
        self.lastStatus = lastStatus
    }
}
