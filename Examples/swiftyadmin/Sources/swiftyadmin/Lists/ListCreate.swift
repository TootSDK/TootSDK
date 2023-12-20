import ArgumentParser
import Foundation
import TootSDK

struct ListCreate: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(name: .short, help: "Title of the list")
    var name: String

    mutating func run() async throws {
        print("Creating list")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        if let list = try? await client.createList(params: .init(title: self.name)) {
            print("Created " + list.id + ", " + list.title)
        } else {
            print("List not created")
        }
    }
}
