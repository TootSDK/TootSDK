//
//  InstanceRule.swift
//
//
//  Created by Dale Price on 10/26/23.
//

import Foundation

/// Represents a rule that server users should follow.
public struct InstanceRule: Codable, Hashable, Identifiable, Sendable {

    /// A translated version of an ``InstanceRule``
    public struct Translation: Codable, Hashable, Sendable {
        /// The text content of a rule.
        public var text: String?
        /// Longer-form description of a rule.
        public var hint: String?

        public init(text: String? = nil, hint: String? = nil) {
            self.text = text
            self.hint = hint
        }
    }

    /// Identifier for the rule.
    ///
    /// > Note: Cast from integer, but not guaranteed to be a number.
    public var id: String
    /// The text content of the rule.
    public var text: String?
    /// Optional text providing more details about the rule.
    public var hint: String?
    /// Available translated versions of the rule's ``text`` and ``hint`` content, keyed by locale code.
    public var translations: [String: Translation]?

    public init(id: String, text: String? = nil, hint: String? = nil, translations: [String: Translation]? = nil) {
        self.id = id
        self.text = text
        self.hint = hint
        self.translations = translations
    }
}
