//
//  ScheduledStatusParams.swift
//  
//
//  Created by dave on 4/12/22.
//

import Foundation

/// Parameters to post a new scheduled status
public struct ScheduledStatusParams: Codable {
    
    ///  Creates parameters to post a new scheduled status
    /// - Parameters:
    ///   - text: The text content of the status. If mediaIds is provided, this becomes optional. Attaching a poll is optional while status is provided.
    ///   - mediaIds: Include Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
    ///   - poll: CreatePoll struct
    ///   - inReplyToId: ID of the status being replied to, if status is a reply.
    ///   - sensitive: Boolean. Mark status and attached media as sensitive? Defaults to false.
    ///   - spoilerText: Text to be shown as a warning or subject before the actual content. Statuses are generally collapsed behind this field.
    ///   - visibility: Sets the visibility of the posted status to public, unlisted, private, direct.
    ///   - language: ISO 639 language code for this status.
    ///   - scheduledAt: UTC Datetime at which to schedule a status. Must be at least 5 minutes in the future.
    ///   - contentType: (Pleroma) The MIME type of the status, it is transformed into HTML by the backend. You can get the list of the supported MIME types with the nodeinfo endpoint.
    ///   - inReplyToConversationId:(Pleroma) Will reply to a given conversation, addressing only the people who are part of the recipient set of that conversation. Sets the visibility to direct.
    public init(text: String? = nil, mediaIds: [String]? = nil, sensitive: Bool? = nil, spoilerText: String? = nil, visibility: Status.Visibility, language: String? = nil, scheduledAt: Date? = nil, poll: CreatePoll? = nil, idempotency: String? = nil, inReplyToId: String? = nil, contentType: String? = nil, inReplyToConversationId: String? = nil) {
        
        self.text = text
        self.mediaIds = mediaIds
        self.sensitive = sensitive
        self.spoilerText = spoilerText
        self.visibility = visibility
        self.language = language
        self.scheduledAt = scheduledAt
        self.poll = poll
        self.idempotency = idempotency
        self.inReplyToId = inReplyToId
        self.contentType = contentType
        self.inReplyToConversationId = inReplyToConversationId
    }
    
    /// The text content of the status. If media_ids is provided, this becomes optional. Attaching a poll is optional while status is provided.
    public var text: String?
    ///  Include Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Text to be shown as a warning or subject before the actual content. Statuses are generally collapsed behind this field.
    public var sensitive: Bool?
    /// Mark status and attached media as sensitive? Defaults to false.
    public var spoilerText: String?
    /// Sets the visibility of the posted status to public, unlisted, private, direct.
    public var visibility: Status.Visibility
    /// ISO 639 language code for this status.
    public var language: String?
    /// UTC Datetime at which to schedule a status.
    public var scheduledAt: Date?
    /// Poll options
    public var poll: CreatePoll?
    /// Unique status to prevent double posting
    public var idempotency: String?
    ///  ID of the status being replied to, if status is a reply.
    public var inReplyToId: String?
    /// (Pleroma) The MIME type of the status, it is transformed into HTML by the backend. You can get the list of the supported MIME types with the nodeinfo endpoint.
    public var contentType: String?
    /// (Pleroma) Will reply to a given conversation, addressing only the people who are part of the recipient set of that conversation. Sets the visibility to direct.
    public var inReplyToConversationId: String?
    
    enum CodingKeys: String, CodingKey {
        case text
        case mediaIds = "media_ids"
        case poll
        case inReplyToId = "in_reply_to_id"
        case sensitive
        case spoilerText = "spoiler_text"
        case visibility
        case language
        case idempotency
        case scheduledAt = "scheduled_at"
        case contentType = "content_type"
        case inReplyToConversationId = "in_reply_to_conversation_id"
    }
}
