// Created by konstantin on 06/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Params to edit a given post
public struct EditPostParams: Codable, Sendable {
    
    public init(post: String, spoilerText: String? = nil, sensitive: Bool? = nil, mediaIds: [String]? = nil, poll: CreatePoll? = nil) {
        self.post = post
        self.spoilerText = spoilerText
        self.sensitive = sensitive
        self.mediaIds = mediaIds
        self.poll = poll
    }
    
    /// The text content of the post. If media_ids is provided, this becomes optional. Attaching a poll is optional while post is provided.
    public var post: String
    /// Text to be shown as a warning or subject before the actual content. Posts are generally collapsed behind this field.
    public var spoilerText: String?
    /// Mark post and attached media as sensitive? Defaults to false.
    public var sensitive: Bool?
    ///  Include Attachment IDs to be attached as media. If provided, post becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Poll options. Note that editing a poll’s options will reset the votes.
    public var poll: CreatePoll?
    
    enum CodingKeys: String, CodingKey {
        case post = "status"
        case spoilerText
        case sensitive
        case mediaIds
        case poll
    }
}
