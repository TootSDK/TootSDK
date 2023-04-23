// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Conversation: Codable, Hashable, Identifiable {
    public var id: String
    public var accounts: [Account]
    public var unread: Bool
    public var lastPost: Post?

    public init(id: String, accounts: [Account], unread: Bool, lastPost: Post?) {
        self.id = id
        self.accounts = accounts
        self.unread = unread
        self.lastPost = lastPost
    }

    enum CodingKeys: String, CodingKey {
        case id
        case accounts
        case unread
        case lastPost = "lastStatus"
    }
}
