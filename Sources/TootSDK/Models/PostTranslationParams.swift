//
//  TranslatePostParams.swift
//
//
//  Created by Philip Chu on 1/30/24.
//

import Foundation

/// Params to translate a post
public struct PostTranslationParams: Codable {
    /// (ISO 639 language code).
    /// The status content will be translated into this language.
    /// Defaults to the user’s current locale.
    public var lang: String

    public init(lang: String) {
        self.lang = lang
    }
}
