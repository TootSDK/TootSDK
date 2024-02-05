//
//  Translation.swift
//
//
//  Created by Philip Chu on 1/30/24.
//

import Foundation

public struct Translation: Codable {

    /// HTML-encoded translated content of the status.
    public var content: String
    /// The translated spoiler warning of the status.
    /// The Mastodon spec incorrectly lists this as spoiler_warning
    public var spoilerText: String
    /// The language of the source text, as auto-detected by the machine translation provider.
    /// ISO 639 language code
    public var detectedSourceLanguage: String
    /// The service that provided the machine translation.
    public var provider: String
    /// The target language
    /// Not in the Mastodon spec, but in the Mastodon code
    public var language: String
}
