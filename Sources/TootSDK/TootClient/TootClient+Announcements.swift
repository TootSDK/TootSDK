//
//  TootClient+Announcements.swift
//
//
//  Created by Philip Chu on 10/19/23.
//

import Foundation

public extension TootClient {

    /// See all currently active announcements set by admins.
    func getAnnouncements() async throws -> [Announcement] {
        try requireFeature(.announcements)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "announcements"])
            $0.method = .get
        }

        return try await fetch([Announcement].self, req)
    }

    /// Dismiss a single notification from the server.
    func dismissAnnouncement(id: String) async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "announcements", id, "dismiss"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }
}

extension TootFeature {

    /// Ability to retrieve announcements
    ///
    public static let announcements = TootFeature(supportedFlavours: [.mastodon, .akkoma, .pleroma])
}