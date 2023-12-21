//
//  ExtendedDescription.swift
//  
//
//  Created by Philip Chu on 12/4/23.
//

import Foundation

public struct ExtendedDescription: Codable, Hashable {

    /// A timestamp of when the extended description was last updated.
    /// Note: this is not optional in the Mastodon spec but in practice sometimes null
    public var updatedAt: Date?
    
    /// The rendered HTML content of the extended description.
    public var content: String

    public init(updatedAt: Date? = nil, content: String) {
        self.updatedAt = updatedAt
        self.content = content
    }
}

