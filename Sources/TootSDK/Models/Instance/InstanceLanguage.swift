//
//  InstanceLanguage.swift
//  TootSDK
//
//  Created by Dale Price on 5/1/25.
//

/// Represents a supported locale.
public struct InstanceLanguage: Codable, Hashable, Sendable {
    /// Two-letter language code.
    public var code: String
    /// The name of the language localized in the instance's primary language.
    public var name: String?

    public init(code: String, name: String? = nil) {
        self.code = code
        self.name = name
    }
}
