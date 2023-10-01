// Created by konstantin on 03/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation

/// Represents a file or media attachment that can be added to a post.
public struct MediaAttachment: Codable, Hashable, Identifiable, Sendable, MediaAttachmentProtocol {

    public init(id: String, type: AttachmentType, url: String, remoteUrl: String? = nil, previewUrl: String? = nil, meta: AttachmentMeta? = nil, description: String? = nil, blurhash: String? = nil) {
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
    public var url: String
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

public enum AttachmentType: String, Codable, Hashable, Sendable {
    ///  Static image
    case image
    /// Video clip
    case video
    /// Looping, soundless animation
    case gifv
    /// Audio track
    case audio
    /// unsupported or unrecognized file type
    case unknown
}

public struct AttachmentMeta: Codable, Hashable, Sendable {

    public var original: AttachmentMetaInfo?
    public var small: AttachmentMetaInfo?
    public var focus: AttachmentMetaFocus?
}

public struct AttachmentMetaInfo: Codable, Hashable, Sendable {
    public var width: Int?
    public var height: Int?
    public var size: String?
    public var aspect: Double?
    public var frameRate: String?
    public var duration: Double?
    public var bitrate: Int?
}

public extension MediaAttachment {
    var aspectRatio: Double? {
        if
            let info = meta?.original,
            let width = info.width,
            let height = info.height,
            width != 0,
            height != 0 {
            let aspectRatio = Double(width) / Double(height)

            return aspectRatio.isNaN ? nil : aspectRatio
        }

        return nil
    }
}

public struct AttachmentMetaFocus: Codable, Hashable, Sendable {
    public var x: Double?
    public var y: Double?
}

public extension AttachmentMetaFocus {
    static let `default` = Self(x: 0, y: 0)
}

public struct UnprocessedMediaAttachment: Codable, Hashable, Identifiable, Sendable, MediaAttachmentProtocol {
    /// Identifier of the `MediaAttachment`
    public var id: String
    /// The type of the attachment.
    public var type: AttachmentType
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

public protocol MediaAttachmentProtocol {
    /// Identifier of the `MediaAttachment`
    var id: String { get }
    /// The type of the attachment.
    var type: AttachmentType { get }
    /// The location of the full-size original attachment on the remote website.
    var remoteUrl: String? { get }
    /// The location of a scaled-down preview of the attachment.
    var previewUrl: String? { get }
    /// Metadata returned by Paperclip, only `original`, `small` and `focus` are serialized.
    var meta: AttachmentMeta? { get }
    /// Alternate text that describes what is in the media attachment, to be used for the visually impaired or when media attachments do not load.
    var description: String? { get }
    /// A hash computed by the BlurHash algorithm, for generating colorful preview thumbnails when media has not been downloaded yet.
    var blurhash: String? { get }
}

public enum UploadedMediaAttachment: Decodable, Identifiable, Sendable {

    /// Represents media attachment which has been processed by server and has url available.
    case uploaded(MediaAttachment)
    /// Represents media attachment which is not yet processed by server and has no url available.
    case unprocessed(UnprocessedMediaAttachment)

    /// Identifier of the `MediaAttachment`
    public var id: String {
        return mediaAttachment.id
    }

    /// The state of media upload operation.
    public var state: State {
        switch self {
        case .uploaded:
            return .uploaded
        case .unprocessed:
            return .serverProcessing
        }
    }

    /// Information about the attachment available for both uploaded and not yet processed attachments.
    public var mediaAttachment: any MediaAttachmentProtocol {
        switch self {
        case .uploaded(let attachment):
            return attachment
        case .unprocessed(let attachment):
            return attachment
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleValueContainer = try decoder.singleValueContainer()
        if try container.decodeIfPresent(String.self, forKey: .url) != nil {
            let attachment = try singleValueContainer.decode(MediaAttachment.self)
            self = .uploaded(attachment)
        } else {
            let attachment = try singleValueContainer.decode(UnprocessedMediaAttachment.self)
            self = .unprocessed(attachment)
        }
    }

    enum CodingKeys: CodingKey {
        case url
    }

    public enum State: Sendable {
        /// The attachment is still being processed by the server
        case serverProcessing
        /// The attachment has been uploaded
        case uploaded
    }
}
