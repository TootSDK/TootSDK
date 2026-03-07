//
//  TranslatePostParams.swift
//
//
//  Created by Philip Chu on 1/30/24.
//

import Foundation

/// Params to translate a post
public struct PostTranslationParams: Codable, Sendable {
    /// (ISO 639 language code).
    /// The post content will be translated into this language.
    /// Defaults to the user’s current locale.
    public var lang: String

    public init(lang: String) {
        self.lang = lang
    }
}
