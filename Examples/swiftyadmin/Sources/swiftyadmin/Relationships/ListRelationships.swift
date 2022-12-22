import ArgumentParser
import Foundation
import TootSDK

struct ListRelationships: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with sufficient permissions.")
  var token: String

  @Option(
    name: .short,
    help:
      "ids of accounts e.g. '-i 1234 -i 1235'"
  )
  var ids: [String] = []

  mutating func run() async throws {
    print("Listing relationships")
    let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

    let results = try await client.getRelationships(by: self.ids)
    for relation in results {
      print("\(relation)")
    }
  }
}
