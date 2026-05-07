//
//  Suggestion.swift
//
//
//  Created by Philip Chu on 5/17/23.
//

import Foundation

/// An account suggested by the server.
public struct Suggestion: Codable, Hashable, Sendable {
    public init(
        source: Source,
        sources: [Source],
        account: Account
    ) {
        self.source = .some(source)
        self.sources = sources.map { .some($0) }
        self.account = account
    }

    /// The reason this account is being suggested.
    public var source: OpenEnum<Source>
    /// A list of reasons this account is being suggested.
    public var sources: [OpenEnum<Source>]
    /// The account being recommended to follow.
    public var account: Account

    public enum Source: String, Codable, Sendable {
        /// This account was manually recommended by your administration team
        case staff
        /// You have interacted with this account previously
        case pastInteractions = "past_interactions"
        /// This account has many reblogs, favourites, and active local followers within the last 30 days
        case global
        /// This account was manually recommended by the administration team. Equivalent to the `staff`
        case featured
        /// This account has many active local followers
        case mostFollowed = "most_followed"
        /// This account had many reblogs and favourites within the last 30 days
        case mostInteractions = "most_interactions"
        /// This account’s profile is similar to the authenticated account’s most recent follows
        case similarToRecentlyFollowed = "similar_to_recently_followed"
        /// This account is followed by people followed by the authenticated account
        case friendsOfFriends = "friends_of_friends"
    }
}
