//
//  Suggestion.swift
//  
//
//  Created by Philip Chu on 5/17/23.
//

import Foundation

/// An account suggested by the server.
public struct Suggestion: Codable, Hashable, Sendable {
    public init(source: Source, account: Account) {
        self.source = source
        self.account = account
    }

    /// The reason this account is being suggested.
    public var source: Source
    /// The account being recommended to follow.
    public var account: Account

    public enum Source: String, Codable, Sendable {
        /// This account was manually recommended by your administration team
        case staff
        /// You have interacted with this account previously
        case pastInteractions = "past_interactions"
        /// This account has many reblogs, favourites, and active local followers within the last 30 days
        case global
    }
}
