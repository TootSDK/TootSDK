// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.

@preconcurrency import struct Foundation.Date

/// Represents a post that will be published at a future scheduled date.
public struct ScheduledPost: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the scheduled post in the database.
    public var id: String
    /// The timestamp for when the status will be posted.
    public var scheduledAt: Date?
    /// The parameters to be used when the post is posted
    public var params: ScheduledPostParams
    /// Media that is attached to this post.
    public var mediaAttachments: [MediaAttachment]
}
