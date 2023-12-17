import ArgumentParser
import Foundation
import TootSDK

struct Unfollow: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(
        name: .short,
        help:
            "id of the account to unfollow"
    )
    var id: String

    mutating func run() async throws {
        print("Following \(id)")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let relationship = try await client.unfollowAccount(by: self.id)
        print(relationship)
    }
}
