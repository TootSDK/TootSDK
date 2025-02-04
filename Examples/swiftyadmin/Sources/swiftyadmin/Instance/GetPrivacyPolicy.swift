import ArgumentParser
import Foundation
import TootSDK

struct GetInstancePrivacyPolicy: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "URL to the instance to connect to")
    var url: String

    mutating func run() async throws {
        let client = TootClient(instanceURL: URL(string: url)!)
        try await client.connect()
        let instance = try await client.getPrivacyPolicy()
        print(instance)
    }
}
