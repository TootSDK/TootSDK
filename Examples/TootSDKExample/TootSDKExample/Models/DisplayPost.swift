//
//  DisplayPost.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import Foundation
import SwiftData

@Model
final class DisplayPost {
    enum Kind: String, Codable {
        case home
        case mention
    }

    @Attribute(.unique)
    var storageID: String
    var id: String
    var kind: String
    var authorName: String
    var authorUsername: String
    var content: String
    var createdAt: Date
    var url: String

    init(kind: Kind, id: String, authorName: String, authorUsername: String, content: String, createdAt: Date, url: String) {
        self.storageID = "\(kind.rawValue):\(id)"
        self.id = id
        self.kind = kind.rawValue
        self.authorName = authorName
        self.authorUsername = authorUsername
        self.content = content
        self.createdAt = createdAt
        self.url = url
    }
}
