// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a user's preferences.
public struct Preferences: Codable, Hashable, Sendable {
    /// Default visibility for new posts. Equivalent to Source#privacy.
    public var postingDefaultVisibility: Post.Visibility
    /// Default sensitivity flag for new posts. Equivalent to Source#sensitive.
    public var postingDefaultSensitive: Bool
    /// Default language for new posts. Equivalent to Source#language
    public var postingDefaultLanguage: String?
    /// Whether media attachments should be automatically displayed or blurred/hidden.
    public var readingExpandMedia: ExpandMedia
    /// Whether CWs should be expanded by default.
    public var readingExpandSpoilers: Bool
    /// Whether to automatically play animated GIFs.
    public var readingAutoplayGifs: Bool?

    enum CodingKeys: String, CodingKey {
        case postingDefaultVisibility = "posting:default:visibility"
        case postingDefaultSensitive = "posting:default:sensitive"
        case postingDefaultLanguage = "posting:default:language"
        case readingExpandMedia = "reading:expand:media"
        case readingExpandSpoilers = "reading:expand:spoilers"
        case readingAutoplayGifs = "reading:autoplay:gifs"
    }

    public enum ExpandMedia: String, Codable, Sendable {
        /// Hide media marked as sensitive
        case `default`
        /// Always show all media by default, regardless of sensitivity
        case showAll = "show_all"
        /// Always hide all media by default, regardless of sensitivity
        case hideAll = "hide_all"
    }
}
