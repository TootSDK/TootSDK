//
//  PostSource.swift
//
//
//  Created by dave on 4/12/22.
//

import Foundation

/// Represents a post's source as plain text.
public struct PostSource: Codable, Identifiable, Sendable {
    /// ID of the post in the database.
    public var id: String
    /// The plain text used to compose the post.
    public var text: String
    /// The plain text used to compose the post subject or content warning.
    public var spoilerText: String
    /// The content type of the status source. Available for Pleroma and Akkoma.
    public var contentType: String?

    public init(id: String, text: String, spoilerText: String, contentType: String? = nil) {
        self.id = id
        self.text = text
        self.spoilerText = spoilerText
        self.contentType = contentType
    }
}
