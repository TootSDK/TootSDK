//
//  FollowAccountParams.swift
//  
//
//  Created by dave on 21/12/22.
//

import Foundation

public struct FollowAccountParams: Codable {
    /// Receive this account’s reblogs in home timeline? Defaults to true.
    var reblogs: Bool = true
    /// Receive notifications when this account posts a status? Defaults to false.
    var notify: Bool = false
    /// Array of String (ISO 639-1 language two-letter code). Filter received statuses for these languages. If not provided, you will receive this account’s posts in all languages.
    var languages: [String]? = nil
    
    /// - Parameters:
    ///   - reblogs: Receive this account’s reblogs in home timeline? Defaults to true.
    ///   - notify: Receive notifications when this account posts a status? Defaults to false.
    ///   - languages: Array of String (ISO 639-1 language two-letter code). Filter received statuses for these languages. If not provided, you will receive this account’s posts in all languages.
    public init(reblogs: Bool = true,
                notify: Bool = false,
                languages: [String]? = nil) {
        self.reblogs = reblogs
        self.notify = notify
        self.languages = languages
    }
}
