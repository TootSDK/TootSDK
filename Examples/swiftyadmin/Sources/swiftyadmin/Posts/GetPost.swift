import ArgumentParser
import Foundation
import TootSDK

struct GetPost: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(
        name: .short,
        help:
            "id of the post to download"
    )
    var id: String

    mutating func run() async throws {
        print("Getting post with local id: \(id)")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let post = try await client.getPost(id: id)
        let json = String.init(data: try TootEncoder().encode(post), encoding: .utf8)
        print(json ?? "")
    }
}
