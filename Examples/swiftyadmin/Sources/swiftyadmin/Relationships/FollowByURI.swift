//
//  FollowURI.swift
//  Created by dave on 22/12/22.
//

import ArgumentParser
import Foundation
import TootSDK

struct FollowByURI: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(
        name: .short,
        help:
            "URI of the account to follow, e.g @test@instance.test"
    )
    var account: String

    mutating func run() async throws {
        print("Following \(account)")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
        let relationship = try await client.followAccountURI(by: account)
        print(relationship)
    }
}
