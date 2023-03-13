//  TootTimeline.swift
//  Created by dave on 13/03/23.

import Foundation

/// Timelines that we can get posts for, or create streams of posts from
public enum TootTimeline: Hashable, Sendable {
    
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
    public static var local: TootTimeline {
        return .local()
    }
    
    /// A stream of the user's federated timeline
    public static var federated: TootTimeline {
        return .federated()
    }
    
    /// Provides the url paths as an array of strings, based on the type of timeline
    /// - Returns: the url paths creatd
    public func getURLPaths() -> [String] {
        switch self {
        case .home:
            return ["api", "v1", "timelines", "home"]
        case .local:
            return ["api", "v1", "timelines", "public"]
        case .federated:
            return ["api", "v1", "timelines", "public"]
        case .favourites:
            return ["api", "v1", "favourites"]
        case .bookmarks:
            return ["api", "v1", "bookmarks"]
        case .hashtag(let hashtagTimelineQuery):
            return ["api", "v1", "timelines", "tag", hashtagTimelineQuery.tag]
        case .list(let listID):
            return ["api", "v1", "timelines", "list", listID]
        }
    }
    
    /// Provides the a timeline query to be used by the get request
    /// - Returns: the timeline query created
    internal func getQuery() -> (any TimelineQuery)? {
        switch self {
        case .local(let localTimelineQuery):
            return localTimelineQuery
        case .federated(let federatedTimelineQuery):
            return federatedTimelineQuery
        case .hashtag(let hashtagTimelineQuery):
            return hashtagTimelineQuery
        case .home, .favourites, .bookmarks, .list:
            return nil
        }
    }
    
}
