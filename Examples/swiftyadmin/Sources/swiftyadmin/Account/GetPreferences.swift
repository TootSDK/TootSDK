import ArgumentParser
import Foundation
import TootSDK

struct GetPreferences: AsyncParsableCommand {
    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    mutating func run() async throws {
        print("Getting account preferences")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let preferences = try await client.getPreferences()
        print(preferences)
    }
}
