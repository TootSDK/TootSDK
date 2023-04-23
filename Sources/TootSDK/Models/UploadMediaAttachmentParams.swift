// Created by konstantin on 03/02/2023.
// Copyright (c) 2023. All rights reserved.

@preconcurrency import struct Foundation.Data

public struct UploadMediaAttachmentParams: Codable, Sendable {

    public init(file: Data, thumbnail: Data? = nil, description: String? = nil, focus: String? = nil) {
        self.file = file
        self.thumbnail = thumbnail
        self.description = description
        self.focus = focus
    }

    /// The file to be attached, encoded using multipart form data. The file must have a MIME
    public let file: Data
    /// The custom thumbnail of the media to be attached, encoded using multipart form data.
    public let thumbnail: Data?
    /// A plain-text description of the media, for accessibility purposes.
    public let description: String?
    /// Two floating points (x,y), comma-delimited, ranging from -1.0 to 1.0
    public let focus: String?
}
