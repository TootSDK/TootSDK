import ArgumentParser
import Foundation
import TootSDK

struct GetConversations: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    mutating func run() async throws {
        let client = try await TootClient(connect: URL(string: url)!, accessToken: token)
        var pagedInfo: PagedInfo? = nil
        var hasMore = true

        while hasMore {
            let page = try await client.getConversations(pagedInfo)
            print("=== page ===")
            for conversation in page.result {
                let json = String.init(data: try TootEncoder().encode(conversation), encoding: .utf8)
                print(json ?? "")
            }
            hasMore = page.hasPrevious
            pagedInfo = page.previousPage
        }
    }
}
