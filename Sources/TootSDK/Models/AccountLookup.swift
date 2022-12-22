//
//  AccountLookup.swift
//  
//
//  Created by dave on 22/12/22.
//

import Foundation

public struct AccountLookup: Codable {
    var id: String
    var username: String
    var acct: String
    var displayName: String
    var locked: Bool
}
