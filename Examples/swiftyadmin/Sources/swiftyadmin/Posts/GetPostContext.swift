import ArgumentParser
import Foundation
import TootSDK

struct GetPostContext: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(
        name: .short,
        help:
            "id of the post for which to retrieve a thread"
    )
    var id: String

    mutating func run() async throws {
        print("Getting post with local id: \(id)")
        let client = try await TootClient(connect: URL(string: url)!, accessToken: token)

        let context = try await client.getContext(id: id)
        let json = String.init(data: try TootEncoder().encode(context), encoding: .utf8)
        print(json ?? "")
    }
}
