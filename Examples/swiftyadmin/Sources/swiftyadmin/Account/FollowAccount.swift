//
//  FollowAccount.swift
//
//
//  Created by Łukasz Rutkowski on 14/01/2024.
//

import ArgumentParser
import Foundation
import TootSDK

struct FollowAccount: AsyncParsableCommand {

    @OptionGroup var auth: AuthOptions

    @Option(name: .shortAndLong, help: "id of the account")
    var id: String

    @Option(help: "Receive notifications when this account posts a post")
    var notify: Bool = false
    @Option(help: "Receive this account’s reposts in home timeline")
    var reposts: Bool = true
    @Option(help: "Array of String (ISO 639-1 language two-letter code). Filter received posts for these languages")
    var languages: [String] = []

    mutating func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }

        let params = FollowAccountParams(
            reposts: reposts,
            notify: notify,
            languages: languages.isEmpty ? nil : languages
        )
        let relationship = try await client.followAccount(by: id, params: params)
        print(relationship)
    }
}
