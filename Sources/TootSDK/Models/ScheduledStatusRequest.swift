// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Internal representation of `ScheduledStatusParams` suitable for multipart requests
internal struct ScheduledStatusRequest: Codable {
    /// The text content of the status. If media_ids is provided, this becomes optional. Attaching a poll is optional while status is provided.
    public var status: String?
    ///  Include Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Text to be shown as a warning or subject before the actual content. Statuses are generally collapsed behind this field.
    public var sensitive: Bool?
    /// Mark status and attached media as sensitive? Defaults to false.
    public var spoilerText: String?
    /// Sets the visibility of the posted status to public, unlisted, private, direct.
    public var visibility: Post.Visibility
    /// ISO 639 language code for this status.
    public var language: String?
    /// UTC Datetime at which to schedule a status in ISO 8601 format
    public var scheduledAt: String?
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
        case status
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

extension ScheduledStatusRequest {
    init(from: ScheduledStatusParams) throws {
        guard let scheduledAtDate = from.scheduledAt else {
            throw TootSDKError.missingParameter(parameterName: "scheduledAt")
        }
        
        if scheduledAtDate < Date().addingTimeInterval(TimeInterval(5.0 * 60.0)) {
            // scheduled_at must be at least 5 mins into the future
            // https://github.com/mastodon/mastodon/pull/9706
            throw TootSDKError.invalidParameter(parameterName: "scheduledAt")
        }
        
        self = ScheduledStatusRequest(status: from.text, mediaIds: from.mediaIds, sensitive: from.sensitive, spoilerText: from.spoilerText, visibility: from.visibility, language: from.language, scheduledAt: TootEncoder.dateFormatter.string(from: scheduledAtDate), poll: from.poll, idempotency: from.idempotency, inReplyToId: from.inReplyToId, contentType: from.contentType, inReplyToConversationId: from.inReplyToConversationId)
    }
}
