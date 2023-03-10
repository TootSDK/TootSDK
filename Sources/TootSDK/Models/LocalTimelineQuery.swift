//
//  File.swift
//  
//
//  Created by Konstantin on 09/03/2023.
//

import Foundation

/// Specifies the parameters for a local timeline request
public struct LocalTimelineQuery: Codable, Sendable {
    public init(onlyMedia: Bool? = nil) {
        self.onlyMedia = onlyMedia
    }
    
    /// Return only statuses with media attachments
    public var onlyMedia: Bool?
}
