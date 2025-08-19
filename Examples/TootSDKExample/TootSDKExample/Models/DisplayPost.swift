//
//  DisplayPost.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import Foundation
import SwiftData

@Model
// A model of a post as used in the UI of the app
final class DisplayPost {
    @Attribute(.unique)
    var id: String
    var authorName: String
    var authorUsername: String
    var content: String
    var createdAt: Date
    var url: String

    init(id: String, authorName: String, authorUsername: String, content: String, createdAt: Date, url: String) {
        self.id = id
        self.authorName = authorName
        self.authorUsername = authorUsername
        self.content = content
        self.createdAt = createdAt
        self.url = url
    }
}
