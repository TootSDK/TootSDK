// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.

@preconcurrency import struct Foundation.Date

/// Represents a post that will be published at a future scheduled date.
public struct ScheduledPost: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the scheduled post in the database.
    public var id: String
    /// The timestamp for when the post will be posted.
    public var scheduledAt: Date?
    /// The parameters to be used when the post is posted
    public var params: ScheduledPostParams
    /// Media that is attached to this post.
    public var mediaAttachments: [MediaAttachment]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.scheduledAt = try container.decodeIfPresent(Date.self, forKey: .scheduledAt)

        let postParams = try container.decode(ScheduledPostParams.self, forKey: .params)
        self.params = postParams

        let attachments = try container.decode([MediaAttachment].self, forKey: .mediaAttachments)

        if let mediaIds = params.mediaIds {
            // sort attachments in the order of mediaIds
            self.mediaAttachments = attachments.sorted(by: { attachmentA, attachmentB in
                guard let aIndex = mediaIds.firstIndex(of: attachmentA.id) else { return false }
                guard let bIndex = mediaIds.firstIndex(of: attachmentB.id) else { return true }
                return aIndex < bIndex
            })
        } else {
            self.mediaAttachments = attachments
        }
    }
}
