//
//  FollowAccountParams.swift
//
//
//  Created by dave on 21/12/22.
//

import Foundation

public struct FollowAccountParams: Codable, Sendable {
    /// Receive notifications when this account posts a post? Defaults to false.
    var notify: Bool?
    /// Receive this account’s reposts in home timeline? Defaults to true.
    var reposts: Bool?
    /// Array of String (ISO 639-1 language two-letter code). Filter received posts for these languages. If not provided, you will receive this account’s posts in all languages.
    var languages: [String]?

    /// - Parameters:
    ///   - reposts: Receive this account’s reposts in home timeline? Defaults to true.
    ///   - notify: Receive notifications when this account posts a post?  Defaults to false.
    ///   - languages: Array of String (ISO 639-1 language two-letter code). Filter received posts for these languages. If not provided, you will receive this account’s posts in all languages.
    public init(
        reposts: Bool? = nil,
        notify: Bool? = nil,
        languages: [String]? = nil
    ) {
        self.notify = notify
        self.languages = languages
        self.reposts = reposts
    }

    enum CodingKeys: String, CodingKey {
        case notify
        case reposts = "reblogs"
        case languages
    }
}
