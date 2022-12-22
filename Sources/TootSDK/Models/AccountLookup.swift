//
//  AccountLookup.swift
//  
//
//  Created by dave on 22/12/22.
//

import Foundation

public struct AccountLookup: Codable {
    public init(id: String, username: String, acct: String, displayName: String, locked: Bool) {
        self.id = id
        self.username = username
        self.acct = acct
        self.displayName = displayName
        self.locked = locked
    }
    
    /// The account id.
    public var id: String
    /// The username of the account, not including domain.
    public var username: String
    /// The Webfinger account URI. Equal to username for local users, or username@domain for remote users.
    public var acct: String?
    /// The profile's display name.
    public var displayName: String?
    /// Whether the account manually approves follow requests
    public var locked: Bool
}
