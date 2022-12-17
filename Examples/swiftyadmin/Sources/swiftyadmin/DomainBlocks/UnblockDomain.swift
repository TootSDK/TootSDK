import ArgumentParser
import Foundation
import TootSDK

struct UnblockDomain: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with sufficient permissions.")
  var token: String

  @Option(name: .short, help: "Your instance's internal id of the domain to be unblocked")
  var id: String

  mutating func run() async throws {
    print("Unblocking domain with id:\(self.id)")
    let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
    try await client.adminUnblockDomain(domain: id)
  }
}
