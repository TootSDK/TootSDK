// Created by konstantin on 30/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Parameters to create a new post
public struct PostParams: Codable {
        
    ///  Creates an object to create a new post with
    /// - Parameters:
    ///   - post: The text content of the post. If media_ids is provided, this becomes optional. Attaching a poll is optional while post is provided.
    ///   - mediaIds: Include Attachment IDs to be attached as media. If provided, post becomes optional, and poll cannot be used.
    ///   - poll: CreatePoll struct
    ///   - inReplyToId: ID of the post being replied to, if post is a reply.
    ///   - sensitive: Boolean. Mark post and attached media as sensitive? Defaults to false.
    ///   - spoilerText: Text to be shown as a warning or subject before the actual content. Posts are generally collapsed behind this field.
    ///   - visibility: Sets the visibility of the posted post to public, unlisted, private, direct.
    ///   - language: ISO 639 language code for this post.
    ///   - contentType: (Pleroma) The MIME type of the post, it is transformed into HTML by the backend. You can get the list of the supported MIME types with the nodeinfo endpoint.
    ///   - inReplyToConversationId:(Pleroma) Will reply to a given conversation, addressing only the people who are part of the recipient set of that conversation. Sets the visibility to direct.
    public init(post: String,
                mediaIds: [String]? = nil,
                poll: CreatePoll? = nil,
                inReplyToId: String? = nil,
                sensitive: Bool? = nil,
                spoilerText: String? = nil,
                visibility: Post.Visibility,
                language: String? = nil,
                contentType: String? = nil,
                inReplyToConversationId: String? = nil) {
        self.post = post
        self.mediaIds = mediaIds
        self.poll = poll
        self.inReplyToId = inReplyToId
        self.sensitive = sensitive
        self.spoilerText = spoilerText
        self.visibility = visibility
        self.language = language
        self.contentType = contentType
        self.inReplyToConversationId = inReplyToConversationId
    }
    
    public init(post: String, visibility: Post.Visibility, spoilerText: String? = nil) {
        self.init(post: post, mediaIds: [], poll: nil, inReplyToId: nil, sensitive: nil, spoilerText: spoilerText, visibility: visibility, language: nil, contentType: nil, inReplyToConversationId: nil)
    }
        
    /// The text content of the post. If media_ids is provided, this becomes optional. Attaching a poll is optional while post is provided.
    public var post: String
    ///  Include Attachment IDs to be attached as media. If provided, post becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Poll options
    public var poll: CreatePoll?
    ///  ID of the post being replied to, if post is a reply.
    public var inReplyToId: String?
    /// Mark post and attached media as sensitive? Defaults to false.
    public var sensitive: Bool?
    /// Text to be shown as a warning or subject before the actual content. Posts are generally collapsed behind this field.
    public var spoilerText: String?
    /// Sets the visibility of the posted post to public, unlisted, private, direct.
    public var visibility: Post.Visibility
    /// ISO 639 language code for this post.
    public var language: String?
    /// (Pleroma) The MIME type of the post, it is transformed into HTML by the backend. You can get the list of the supported MIME types with the nodeinfo endpoint.
    public var contentType: String?
    
    /// (Pleroma) Will reply to a given conversation, addressing only the people who are part of the recipient set of that conversation. Sets the visibility to direct.
    public var inReplyToConversationId: String?
    
    enum CodingKeys: String, CodingKey {
        case post = "status"
        case mediaIds = "media_ids"
        case poll
        case inReplyToId = "in_reply_to_id"
        case sensitive
        case spoilerText = "spoiler_text"
        case visibility
        case language
        case contentType = "content_type"
        case inReplyToConversationId = "in_reply_to_conversation_id"
    }
}
