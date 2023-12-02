//
//  UpdateMarkers.swift
//  
//
//  Created by Łukasz Rutkowski on 02/12/2023.
//

import Foundation
import ArgumentParser
import TootSDK

struct UpdateMarkers: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(name: .long)
    var home: String?

    @Option(name: .long)
    var notifications: String?

    mutating func run() async throws {
        let client = try await TootClient(connect: URL(string: url)!, accessToken: token)
        client.debugOn()
        let markers = try await client.updateMarkers(homeLastReadId: home, notificationsLastReadId: notifications)
        print(markers)
    }
}
