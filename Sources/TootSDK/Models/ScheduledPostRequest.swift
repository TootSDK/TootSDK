// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Internal representation of `ScheduledPostParams` suitable for multipart requests
internal struct ScheduledPostRequest: Codable {
    /// The text content of the post. If media_ids is provided, this becomes optional. Attaching a poll is optional while post is provided.
    public var post: String?
    ///  Include Attachment IDs to be attached as media. If provided, post becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Text to be shown as a warning or subject before the actual content. Posts are generally collapsed behind this field.
    public var sensitive: Bool?
    /// Mark post and attached media as sensitive? Defaults to false.
    public var spoilerText: String?
    /// Sets the visibility of the posted post to public, unlisted, private, direct.
    public var visibility: OpenEnum<Post.Visibility>
    /// ISO 639 language code for this post.
    public var language: String?
    /// UTC Datetime at which to schedule a post in ISO 8601 format
    public var scheduledAt: String?
    /// Poll options
    public var poll: CreatePoll?
    /// Unique post to prevent double posting
    public var idempotency: String?
    ///  ID of the post being replied to, if post is a reply.
    public var inReplyToId: String?
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
        case idempotency
        case scheduledAt = "scheduled_at"
        case contentType = "content_type"
        case inReplyToConversationId = "in_reply_to_conversation_id"
    }
}

extension ScheduledPostRequest {
    init(from: ScheduledPostParams) throws {
        guard let scheduledAtDate = from.scheduledAt else {
            throw TootSDKError.missingParameter(parameterName: "scheduledAt")
        }

        if scheduledAtDate < Date().addingTimeInterval(TimeInterval(5.0 * 60.0)) {
            // scheduled_at must be at least 5 mins into the future
            // https://github.com/mastodon/mastodon/pull/9706
            throw TootSDKError.invalidParameter(
                parameterName: "scheduledAt",
                reason: "The scheduled date must be at least 5 minutes into the future."
            )
        }

        self = ScheduledPostRequest(
            post: from.text, mediaIds: from.mediaIds, sensitive: from.sensitive, spoilerText: from.spoilerText, visibility: from.visibility,
            language: from.language, scheduledAt: TootEncoder.dateFormatter.string(from: scheduledAtDate), poll: from.poll,
            idempotency: from.idempotency, inReplyToId: from.inReplyToId, contentType: from.contentType,
            inReplyToConversationId: from.inReplyToConversationId)
    }
}
