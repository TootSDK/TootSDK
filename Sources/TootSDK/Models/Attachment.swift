// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Attachment: Codable, Hashable {
    public enum AttachmentType: String, Codable, Hashable {
        case image, video, gifv, audio, unknown
    }

    public struct Meta: Codable, Hashable {

        // swiftlint:disable nesting
        public struct Info: Codable, Hashable {
            public var width: Int?
            public var height: Int?
            public var size: String?
            public var aspect: Double?
            public var frameRate: String?
            public var duration: Double?
            public var bitrate: Int?
        }

        public struct Focus: Codable, Hashable {
            public var x: Double
            public var y: Double
        }

        public var original: Info?
        public var small: Info?
        public var focus: Focus?
    }
    // swiftlint:enable nesting

    public var id: String
    public var type: AttachmentType
    public var url: String
    public var remoteUrl: String?
    public var previewUrl: String?
    public var meta: Meta?
    public var description: String?
    public var blurhash: String?
}

public extension Attachment {
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

public extension Attachment.Meta.Focus {
    static let `default` = Self(x: 0, y: 0)
}
