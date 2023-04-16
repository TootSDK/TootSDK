// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Emoji: Codable, Hashable, Sendable {
    /// The name of the custom emoji.
    public var shortcode: String
    /// A link to the custom emoji.
    public var url: String
    /// A link to a static copy of the custom emoji.
    public var staticUrl: String
    ///  Whether this Emoji should be visible in the picker or unlisted.
    public var visibleInPicker: Bool
    /// Used for sorting custom emoji in the picker.
    public var category: String?
}
