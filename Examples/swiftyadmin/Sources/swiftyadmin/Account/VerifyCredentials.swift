//
//  VerifyCredentials.swift
//  swiftyadmin
//
//  Created by Dale Price on 7/17/25.
//

import ArgumentParser
import Foundation
import TootSDK

struct VerifyCredentials: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    mutating func run() async throws {
        print("Verifying account credentials")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let credentialAccount = try await client.verifyCredentials()
        print(credentialAccount)
        if let source = credentialAccount.source {
            print(source)
        }
    }
}
