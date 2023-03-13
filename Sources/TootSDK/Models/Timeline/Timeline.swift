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
    
    /// A stream of the user's local timeline
    public static var local: Timeline {
        return .local()
    }
    
    /// A stream of the user's federated timeline
    public static var federated: Timeline {
        return .federated()
    }
    
}
