//
//  GetMarkers.swift
//
//
//  Created by Łukasz Rutkowski on 02/12/2023.
//

import ArgumentParser
import Foundation
import TootSDK

struct GetMarkers: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(
        name: .long, parsing: .remaining,
        transform: { rawValue in
            guard let timeline = Marker.Timeline(rawValue: rawValue) else {
                throw ValidationError("Unknown timeline")
            }
            return timeline
        })
    var timelines: [Marker.Timeline]

    mutating func run() async throws {
        let client = try await TootClient(connect: URL(string: url)!, accessToken: token)
        client.debugOn()
        let markers = try await client.getMarkers(for: Set(timelines))
        print(markers)
    }
}
