import ArgumentParser
import Foundation
import TootSDK

struct BlockDomain: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with sufficient permissions.")
  var token: String

  @Option(name: .short, help: "The domain to be blocked")
  var domain: String

  mutating func run() async throws {
    print("Blocking domain \(self.domain)")
    let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
    let _ = try await client.adminBlockDomain(params: BlockDomainParams(domain: domain))
  }
}
