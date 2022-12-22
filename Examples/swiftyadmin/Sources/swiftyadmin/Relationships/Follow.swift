import ArgumentParser
import Foundation
import TootSDK

struct Follow: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with sufficient permissions.")
  var token: String

  @Option(
    name: .short,
    help:
      "id of the account to follow"
  )
  var id: String

  @Option(
    name: .long,
    help:
      "Receive notifications when this account posts a status?"
  )
  var notify: String?

  mutating func run() async throws {
    print("Following \(id)")
    let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
    if let notifystr = notify, let notify = Bool(notifystr) {
      let relationship = try await client.followAccount(by: id, params: .init(notify: notify))
      print(relationship)
    } else {
      let relationship = try await client.followAccount(by: id)
      print(relationship)
    }
  }
}
