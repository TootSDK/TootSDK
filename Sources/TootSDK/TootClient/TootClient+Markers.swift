//
//  TootClient+Markers.swift
//
//
//  Created by Łukasz Rutkowski on 02/12/2023.
//

import Foundation

public extension TootClient {
    func getMarkers(for timelines: Set<Marker.Timeline>) async throws -> [Marker.Timeline: Marker] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "markers"])
            $0.method = .get
            $0.query = createQuery(timelines: timelines)
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
