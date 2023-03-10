//
//  File.swift
//  
//
//  Created by Konstantin on 09/03/2023.
//

import Foundation

/// Specifies the parameters for a hashtag timeline request
public struct HashtagTimelineQuery: Codable, Sendable {
    public init(tag: String, anyTags: [String]? = nil, allTags: [String]? = nil, noneTags: [String]? = nil, onlyMedia: Bool? = nil, local: Bool? = nil, remote: Bool? = nil) {
        self.tag = tag
        self.anyTags = anyTags
        self.allTags = allTags
        self.noneTags = noneTags
        self.onlyMedia = onlyMedia
        self.local = local
        self.remote = remote
    }
    
    /// The name of the hashtag, not including the `#` symbol
    public var tag: String
    
    /// Return statuses that contain any of these additional tags
    public var anyTags: [String]?
    
    /// Return statuses that contain all of these additional tags
    public var allTags: [String]?
    
    /// Return statuses that contain none of these additional tags
    public var noneTags: [String]?
    
    /// Return only statuses with media attachments
    public var onlyMedia: Bool?
    
    /// Return only local statuses
    public var local: Bool?
    
    /// Return only remote statuses
    public var remote: Bool?
}
