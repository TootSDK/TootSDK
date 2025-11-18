// Created by konstantin on 06/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Params to edit a given post
public struct EditPostParams: Codable, Sendable {

    public init(
        post: String,
        spoilerText: String? = nil,
        sensitive: Bool? = nil,
        quoteApprovalPolicy: QuotePolicy? = nil,
        language: String? = nil,
        mediaIds: [String]? = nil,
        mediaAttributes: [MediaAttribute]? = nil,
        poll: CreatePoll? = nil
    ) {
        self.post = post
        self.spoilerText = spoilerText
        self.sensitive = sensitive
        self.quoteApprovalPolicy = quoteApprovalPolicy
        self.language = language
        self.mediaIds = mediaIds
        self.mediaAttributes = mediaAttributes
        self.poll = poll
    }

    /// The text content of the post. If media_ids is provided, this becomes optional. Attaching a poll is optional while post is provided.
    public var post: String
    /// Text to be shown as a warning or subject before the actual content. Posts are generally collapsed behind this field.
    public var spoilerText: String?
    /// Mark post and attached media as sensitive? Defaults to false.
    public var sensitive: Bool?
    /// Policy to quote this post: public, followers or nobody. If omitted, it will use the user’s default settings; If the status’ visibility is private or direct, this parameter will be ignored and the policy be set to nobody.
    public var quoteApprovalPolicy: QuotePolicy?
    /// ISO 639 language code for the post.
    public var language: String?
    /// Include Attachment IDs to be attached as media. If provided, post becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Attributes of media to update.
    public var mediaAttributes: [MediaAttribute]?
    /// Poll options. Note that editing a poll’s options will reset the votes.
    public var poll: CreatePoll?

    enum CodingKeys: String, CodingKey {
        case post = "status"
        case spoilerText = "spoiler_text"
        case sensitive
        case quoteApprovalPolicy = "quote_approval_policy"
        case language
        case mediaIds = "media_ids"
        case mediaAttributes = "media_attributes"
        case poll
    }

    public struct MediaAttribute: Codable, Sendable {
        /// Id of media attachment.
        public var id: String
        /// New alt text description for the media attachment.
        public var description: String?
        /// New focus point for the media attachment.
        public var focus: String?

        public init(id: String, description: String? = nil, focus: String? = nil) {
            self.id = id
            self.description = description
            self.focus = focus
        }
    }
}
