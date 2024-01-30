//
//  Translation.swift
//  
//
//  Created by Philip Chu on 1/30/24.
//

import Foundation

public struct Translation: Codable {
    
    public var content: String
    public var spoilerWarning: String
    public var detectedSourceLanguage: String
    public var provider: String
}
