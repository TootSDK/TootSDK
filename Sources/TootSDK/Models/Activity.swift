// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a weekly bucket of instance activity.
public struct Activity: Codable, Hashable {
    public init(week: Date, posts: Int, logins: Int, registrations: Int) {
        self.week = week
        self.posts = posts
        self.logins = logins
        self.registrations = registrations
    }

    /// Midnight at the first day of the week.
    var week: Date
    /// posts created since the week began.
    var posts: Int
    /// User logins since the week began.
    var logins: Int
    /// User registrations since the week began.
    var registrations: Int

    enum CodingKeys: String, CodingKey {
        case week
        case posts = "statuses"
        case logins
        case registrations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let posts = Int(try container.decode(String.self, forKey: .posts)) else {
            throw TootSDKError.decodingError("posts")
        }
        self.posts = posts

        guard let logins = Int(try container.decode(String.self, forKey: .logins)) else {
            throw TootSDKError.decodingError("logins")
        }
        self.logins = logins

        guard let registrations = Int(try container.decode(String.self, forKey: .registrations)) else {
            throw TootSDKError.decodingError("registrations")
        }
        self.registrations = registrations

        guard let weekUnixEpoc = Int(try container.decode(String.self, forKey: .week)) else {
            throw TootSDKError.decodingError("weekUnixEpoc")
        }
        self.week = Date(timeIntervalSince1970: TimeInterval(weekUnixEpoc))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(Int(week.timeIntervalSince1970)), forKey: .week)
        try container.encode(String(posts), forKey: .posts)
        try container.encode(String(logins), forKey: .logins)
        try container.encode(String(registrations), forKey: .registrations)
    }
}
