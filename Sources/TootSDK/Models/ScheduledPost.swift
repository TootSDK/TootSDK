// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a post that will be published at a future scheduled date.
public struct ScheduledPost: Codable, Sendable {
    /// ID of the scheduled post in the database.
    public var id: String
    /// ID of the post in the database.
    public var scheduledAt: Date?
    /// The parameters to be used when the post is posted
    public var params: ScheduledPostParams
    /// Media that is attached to this post.
    public var mediaAttachments: [Attachment]
}
