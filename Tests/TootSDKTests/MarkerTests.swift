//
//  Test.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 23/02/2025.
//

import Foundation
import Testing

@testable import TootSDK

@Suite struct MarkerTests {
    @Test func decodeMarkerWithUnixTimestamp() async throws {
        let json = localContent("markers_unix_timestamp")
        let decoder = TootDecoder()

        let result = try decoder.decode([Marker.Timeline: Marker].self, from: json)
        #expect(
            result == [
                .notifications: Marker(
                    lastReadId: "1736969839000000",
                    updatedAt: Date(timeIntervalSince1970: 1740308876.000000),
                    version: 0
                )
            ]
        )
    }
}
