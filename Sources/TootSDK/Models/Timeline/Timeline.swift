//  TootTimeline.swift
//  Created by dave on 13/03/23.

import Foundation

/// Timelines that we can get posts for, or create streams of posts from
public enum Timeline: Hashable, Sendable {
    
    /// The user's home timeline
    case home
    
    /// The user's local timeline
    case local(LocalTimelineQuery = LocalTimelineQuery())
    
    /// The user's federated timeline
    case federated(FederatedTimelineQuery = FederatedTimelineQuery())
    
    /// The user's favourite posts
    case favourites
    
    /// The user's bookmarked posts
    case bookmarks
    
    /// Posts matching the hashtag requested
    case hashtag(HashtagTimelineQuery)
    
    /// The user's list matching that id
    case list(listID: String)

    /// Timeline with posts submitted by a single user
    case user(UserTimelineQuery)
    
    /// The user's local timeline
    public static var local: Timeline {
        return .local()
    }
    
    /// The user's federated timeline
    public static var federated: Timeline {
        return .federated()
    }

    /// Timeline with posts submitted by a single user
    public static func user(userID: String) -> Timeline {
        return .user(UserTimelineQuery(userId: userID))
    }
}
