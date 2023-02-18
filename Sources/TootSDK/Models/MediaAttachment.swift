// Created by konstantin on 03/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation

public struct MediaAttachment: Codable, Hashable, Sendable {
    
    public init(id: String, type: AttachmentType, url: String? = nil, remoteUrl: String? = nil, previewUrl: String? = nil, meta: AttachmentMeta? = nil, description: String? = nil, blurhash: String? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.remoteUrl = remoteUrl
        self.previewUrl = previewUrl
        self.meta = meta
        self.description = description
        self.blurhash = blurhash
    }
    
    /// The ID of the attachment in the database.
    public var id: String
    /// The type of the attachment.
    public var type: AttachmentType
    /// The location of the original full-size attachment.
    public var url: String?
    /// The location of the full-size original attachment on the remote website.
    public var remoteUrl: String?
    /// The location of a scaled-down preview of the attachment.
    public var previewUrl: String?
    /// Metadata returned by Paperclip, only `original`, `small` and `focus` are serialized.
    public var meta: AttachmentMeta?
    /// Alternate text that describes what is in the media attachment, to be used for the visually impaired or when media attachments do not load.
    public var description: String?
    /// A hash computed by the BlurHash algorithm, for generating colorful preview thumbnails when media has not been downloaded yet.
    public var blurhash: String?
}
