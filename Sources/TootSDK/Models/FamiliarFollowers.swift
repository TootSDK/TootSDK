//
//  FamiliarFollowers.swift
//
//
//  Created by Philip Chu on 8/22/23.
//

import Foundation

/// Represents a subset of your follows who also follow some other user.
public struct FamiliarFollowers: Codable, Hashable, Identifiable {
    /// The ID of the Account in the database.
    public var id: String
    /// Accounts you follow that also follow this account.
    public var accounts: [Account]
}
