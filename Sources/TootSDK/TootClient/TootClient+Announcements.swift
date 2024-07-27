//
//  TootClient+Announcements.swift
//
//
//  Created by Philip Chu on 10/19/23.
//

import Foundation

extension TootClient {

    /// See all currently active announcements set by admins.
    public func getAnnouncements(params: AnnouncementParams = .init()) async throws -> [Announcement] {
        try requireFeature(.announcements)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "announcements"])
            $0.method = .get
            $0.query = params.queryItems
        }

        return try await fetch([Announcement].self, req)
    }

    /// Dismiss a single notification from the server.
    public func dismissAnnouncement(id: String) async throws {
        try requireFeature(.announcements)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "announcements", id, "dismiss"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }

    /// React to an announcement with an emoji.
    /// - Parameters:
    ///   - id: The ID of the Announcement in the database.
    ///   - name: Unicode emoji, or the shortcode of a custom emoji.
    public func addAnnouncementReaction(id: String, name: String) async throws {
        try requireFeature(.announcements)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "announcements", id, "reactions", name])
            $0.method = .put
        }

        _ = try await fetch(req: req)
    }

    /// Undo a react emoji to an announcement.
    /// - Parameters:
    ///   - id: The ID of the Announcement in the database.
    ///   - name: Unicode emoji, or the shortcode of a custom emoji.
    public func removeAnnouncementReaction(id: String, name: String) async throws {
        try requireFeature(.announcements)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "announcements", id, "reactions", name])
            $0.method = .delete
        }

        _ = try await fetch(req: req)
    }
}

extension TootFeature {

    /// Ability to retrieve announcements
    ///
    public static let announcements = TootFeature(supportedFlavours: [.mastodon, .akkoma, .pleroma, .pixelfed, .firefish, .sharkey, .catodon, .iceshrimp])
}
