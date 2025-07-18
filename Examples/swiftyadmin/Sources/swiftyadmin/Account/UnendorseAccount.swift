//
//  EndorseAccount.swift
//  swiftyadmin
//
//  Created by Dale Price on 7/17/25.
//

import ArgumentParser
import Foundation
import TootSDK

struct UnendorseAccount: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(name: .customShort("i"), help: "id of the user to unendorse")
    var userID: String

    mutating func run() async throws {
        print("Unendorsing user with local id: \(userID)")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let relationship = try await client.unendorseAccount(by: userID)
        print(relationship)
    }
}
