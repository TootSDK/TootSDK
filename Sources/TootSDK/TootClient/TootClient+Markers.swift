//
//  TootClient+Markers.swift
//
//
//  Created by Łukasz Rutkowski on 02/12/2023.
//

import Foundation

public extension TootClient {
    /// Get saved timeline positions
    ///
    /// - Parameter timelines: The timeline(s) for which markers should be fetched.
    func getMarkers(for timelines: Set<Marker.Timeline>) async throws -> [Marker.Timeline: Marker] {
        try requireFeature(.markers)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "markers"])
            $0.method = .get
            $0.query = createQuery(timelines: timelines)
        }
        return try await fetch([Marker.Timeline: Marker].self, req)
    }

    /// Save your position in a timeline
    ///
    /// - Parameters:
    ///   - homeLastReadId: ID of the last status read in the home timeline.
    ///   - notificationsLastReadId: ID of the last notification read.
    @discardableResult
    func updateMarkers(
        homeLastReadId: String? = nil,
        notificationsLastReadId: String? = nil
    ) async throws -> [Marker.Timeline: Marker] {
        try requireFeature(.markers)
        var queryItems: [URLQueryItem] = []
        if let homeLastReadId {
            queryItems.append(URLQueryItem(name: "home[last_read_id]", value: homeLastReadId))
        }
        if let notificationsLastReadId {
            queryItems.append(URLQueryItem(name: "notifications[last_read_id]", value: notificationsLastReadId))
        }
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "markers"])
            $0.method = .post
            $0.body = try .form(queryItems: queryItems)
        }

        return try await fetch([Marker.Timeline: Marker].self, req)
    }

    private func createQuery(timelines: Set<Marker.Timeline>) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        for timeline in timelines {
            queryItems.append(URLQueryItem(name: "timeline[]", value: timeline.rawValue))
        }
        return queryItems
    }
}

extension TootFeature {
    public static let markers = TootFeature(supportedFlavours: [.mastodon, .pleroma, .friendica, .akkoma])
}
