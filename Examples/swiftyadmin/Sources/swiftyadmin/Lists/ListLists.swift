import ArgumentParser
import Foundation
import TootSDK

struct ListLists: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with sufficient permissions.")
  var token: String

  mutating func run() async throws {
    print("Listing lists")
    let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

    let results = try await client.getLists()
    for list in results {
      print(list.id + ", " + list.title)
    }
  }
}
