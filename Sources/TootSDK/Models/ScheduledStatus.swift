// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a status that will be published at a future scheduled date.
public struct ScheduledStatus: Codable {
    /// ID of the scheduled status in the database.
    public var id: String
    /// ID of the status in the database.
    public var scheduledAt: Date?
    /// The parameters to be used when the status is posted
    public var params: ScheduledStatusParams
    /// Media that is attached to this status.
    public var mediaAttachments: [Attachment]
}
