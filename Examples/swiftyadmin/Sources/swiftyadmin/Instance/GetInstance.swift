import ArgumentParser
import Foundation
import TootSDK

struct GetInstance: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "URL to the instance to connect to")
    var url: String

    mutating func run() async throws {
        let client = TootClient(instanceURL: URL(string: url)!)
        let instance = try await client.getInstanceInfo()
        print(instance)
    }
}
