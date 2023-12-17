import ArgumentParser
import Foundation
import TootSDK

struct ListDelete: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(name: .short, help: "Id of the list to delete")
    var id: String

    mutating func run() async throws {
        print("Deleting list")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
        try await client.deleteList(id: self.id)
    }
}
