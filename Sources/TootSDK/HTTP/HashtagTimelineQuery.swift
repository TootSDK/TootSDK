//
//  HashtagTimelineQuery.swift
//  
//
//  Created by Dale Price on 3/7/23.
//

import Foundation

/// Specifies the parameters for a hashtag timeline request
public struct HashtagTimelineQuery: Codable, Sendable {
    
    /// The name of the hashtag, not including the `#` symbol
    public var tag: String
    
    /// Return statuses that contain any of these additional tags
    public var anyTags: [String]? = nil
    
    /// Return statuses that contain all of these additional tags
    public var allTags: [String]? = nil
    
    /// Return statuses that contain none of these additional tags
    public var noneTags: [String]? = nil
    
    /// Return only statuses with media attachments
    public var onlyMedia: Bool? = nil
    
    /// Whether to return only local, only remote statuses, or explicitly not filter by source (optional, if not specified, uses Mastodon default of not filtering)
    public var locality: TimelineLocality? = nil
}
