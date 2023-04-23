// Created by Łukasz Rutkowski on 05/03/2023.
// Copyright (c) 2023. All rights reserved.

@preconcurrency import struct Foundation.Data

public struct UpdateMediaAttachmentParams: Codable, Sendable {

    public init(description: String? = nil, focus: String? = nil) {
        self.thumbnail = nil
        self.thumbnailMimeType = nil
        self.description = description
        self.focus = focus
    }

    public init(thumbnail: Data, thumbnailMimeType: String, description: String? = nil, focus: String? = nil) {
        self.thumbnail = thumbnail
        self.thumbnailMimeType = thumbnailMimeType
        self.description = description
        self.focus = focus
    }

    /// The custom thumbnail of the media to be attached, encoded using multipart form data.
    public let thumbnail: Data?
    /// The mime type of thumbnail.
    public let thumbnailMimeType: String?
    /// A plain-text description of the media, for accessibility purposes.
    public let description: String?
    /// Two floating points (x,y), comma-delimited, ranging from -1.0 to 1.0
    public let focus: String?
}
