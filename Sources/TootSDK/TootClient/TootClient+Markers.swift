//
//  TootClient+Markers.swift
//
//
//  Created by Łukasz Rutkowski on 02/12/2023.
//

import Foundation

extension TootClient {
    /// Get saved timeline positions
    ///
    /// - Parameter timelines: The timeline(s) for which markers should be fetched.
    public func getMarkers(for timelines: Set<Marker.Timeline>) async throws -> [OpenEnum<Marker.Timeline>: Marker] {
        let response = try await getMarkersRaw(for: timelines)
        return response.data
    }

    /// Get saved timeline positions with HTTP response metadata
    ///
    /// - Parameter timelines: The timeline(s) for which markers should be fetched.
    /// - Returns: TootResponse containing the markers and HTTP metadata
    public func getMarkersRaw(for timelines: Set<Marker.Timeline>) async throws -> TootResponse<[OpenEnum<Marker.Timeline>: Marker]> {
        try requireFeature(.markers)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "markers"])
            $0.method = .get
            $0.query = createQuery(timelines: timelines)
        }
        return try await fetchRaw([OpenEnum<Marker.Timeline>: Marker].self, req)
    }

    /// Save your position in a timeline
    ///
    /// - Parameters:
    ///   - homeLastReadId: ID of the last status read in the home timeline.
    ///   - notificationsLastReadId: ID of the last notification read.
    @discardableResult
    public func updateMarkers(
        homeLastReadId: String? = nil,
        notificationsLastReadId: String? = nil
    ) async throws -> [OpenEnum<Marker.Timeline>: Marker] {
        let response = try await updateMarkersRaw(homeLastReadId: homeLastReadId, notificationsLastReadId: notificationsLastReadId)
        return response.data
    }

    /// Save your position in a timeline with HTTP response metadata
    ///
    /// - Parameters:
    ///   - homeLastReadId: ID of the last status read in the home timeline.
    ///   - notificationsLastReadId: ID of the last notification read.
    /// - Returns: TootResponse containing the updated markers and HTTP metadata
    @discardableResult
    public func updateMarkersRaw(
        homeLastReadId: String? = nil,
        notificationsLastReadId: String? = nil
    ) async throws -> TootResponse<[OpenEnum<Marker.Timeline>: Marker]> {
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

        return try await fetchRaw([OpenEnum<Marker.Timeline>: Marker].self, req)
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
    /// Ability to save timeline positions.
    public static let markers = TootFeature(supportedFlavours: [.mastodon, .pleroma, .friendica, .akkoma, .goToSocial])
}
