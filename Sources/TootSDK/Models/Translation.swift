//
//  Translation.swift
//  
//
//  Created by Philip Chu on 1/30/24.
//

import Foundation

public struct Translation: Codable {
    
    var content: String
    var spoilerWarning: String
    var detectedSourceLanguage: String
    var provider: String
}
