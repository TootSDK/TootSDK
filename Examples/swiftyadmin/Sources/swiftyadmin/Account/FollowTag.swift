//
//  FollowTag.swift
//  Created by Łukasz Rutkowski on 21/04/2023.
//

import ArgumentParser
import Foundation
import TootSDK

struct FollowTag: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(name: .shortAndLong, help: "id of the tag")
    var id: String

    mutating func run() async throws {
        print("Getting tag with local id: \(id)")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let tag = try await client.followTag(id)
        print(tag)
    }
}
