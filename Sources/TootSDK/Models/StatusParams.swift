// Created by konstantin on 30/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Parameters to post a new status
public struct StatusParams: Codable {
        
    ///  Creates an object to post a new status
    /// - Parameters:
    ///   - status: The text content of the status. If media_ids is provided, this becomes optional. Attaching a poll is optional while status is provided.
    ///   - mediaIds: Include Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
    ///   - poll: CreatePoll struct
    ///   - inReplyToId: ID of the status being replied to, if status is a reply.
    ///   - sensitive: Boolean. Mark status and attached media as sensitive? Defaults to false.
    ///   - spoilerText: Text to be shown as a warning or subject before the actual content. Statuses are generally collapsed behind this field.
    ///   - visibility: Sets the visibility of the posted status to public, unlisted, private, direct.
    ///   - language: ISO 639 language code for this status.
    ///   - contentType: (Pleroma) The MIME type of the status, it is transformed into HTML by the backend. You can get the list of the supported MIME types with the nodeinfo endpoint.
    ///   - inReplyToConversationId:(Pleroma) Will reply to a given conversation, addressing only the people who are part of the recipient set of that conversation. Sets the visibility to direct.
    public init(status: String,
                mediaIds: [String]? = nil,
                poll: CreatePoll? = nil,
                inReplyToId: String? = nil,
                sensitive: Bool? = nil,
                spoilerText: String? = nil,
                visibility: Status.Visibility,
                language: String? = nil,
                contentType: String? = nil,
                inReplyToConversationId: String? = nil) {
        self.status = status
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
    
    public init(status: String, visibility: Status.Visibility, spoilerText: String? = nil) {
        self.init(status: status, mediaIds: [], poll: nil, inReplyToId: nil, sensitive: nil, spoilerText: spoilerText, visibility: visibility, language: nil, contentType: nil, inReplyToConversationId: nil)
    }
        
    /// The text content of the status. If media_ids is provided, this becomes optional. Attaching a poll is optional while status is provided.
    public var status: String
    ///  Include Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Poll options
    public var poll: CreatePoll?
    ///  ID of the status being replied to, if status is a reply.
    public var inReplyToId: String?
    /// Mark status and attached media as sensitive? Defaults to false.
    public var sensitive: Bool?
    /// Text to be shown as a warning or subject before the actual content. Statuses are generally collapsed behind this field.
    public var spoilerText: String?
    /// Sets the visibility of the posted status to public, unlisted, private, direct.
    public var visibility: Status.Visibility
    /// ISO 639 language code for this status.
    public var language: String?
    /// (Pleroma) The MIME type of the status, it is transformed into HTML by the backend. You can get the list of the supported MIME types with the nodeinfo endpoint.
    public var contentType: String?
    
    /// (Pleroma) Will reply to a given conversation, addressing only the people who are part of the recipient set of that conversation. Sets the visibility to direct.
    public var inReplyToConversationId: String?
    
    enum CodingKeys: String, CodingKey {
        case status
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
