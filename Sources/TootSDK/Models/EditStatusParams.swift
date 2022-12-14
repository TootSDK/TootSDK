// Created by konstantin on 06/12/2022.
// Copyright (c) 2022. All rights reserved.



import Foundation

/// Params to edit a given status
public struct EditStatusParams: Codable {
    public init(status: String, spoilerText: String? = nil, sensitive: Bool? = nil, mediaIds: [String]? = nil, poll: CreatePoll? = nil) {
        self.status = status
        self.spoilerText = spoilerText
        self.sensitive = sensitive
        self.mediaIds = mediaIds
        self.poll = poll
    }
    
    /// The text content of the status. If media_ids is provided, this becomes optional. Attaching a poll is optional while status is provided.
    public var status: String
    /// Text to be shown as a warning or subject before the actual content. Statuses are generally collapsed behind this field.
    public var spoilerText: String?
    /// Mark status and attached media as sensitive? Defaults to false.
    public var sensitive: Bool?
    ///  Include Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
    public var mediaIds: [String]?
    /// Poll options. Note that editing a poll’s options will reset the votes.
    public var poll: CreatePoll?
}
