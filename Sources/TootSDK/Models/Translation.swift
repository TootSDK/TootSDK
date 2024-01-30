//
//  Translation.swift
//  
//
//  Created by Philip Chu on 1/30/24.
//

import Foundation

public struct Translation: Codable {
    
    public var content: String
 // mastodon spec incorrectly lists as spoiler_warning
    public var spoilerText: String
    public var detectedSourceLanguage: String
    public var provider: String
}
