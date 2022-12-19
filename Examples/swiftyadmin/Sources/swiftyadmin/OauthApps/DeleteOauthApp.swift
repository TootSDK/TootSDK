import ArgumentParser
import Foundation
import TootSDK

struct DeleteOauthApp: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with the admin:write claim")
  var token: String

  @Option(name: .short, help: "The app id to be removed")
  var id: Int

  mutating func run() async throws {
    print("Deleting app id \(id):")
    let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
    client.flavour = .pleroma
    let _ = try await client.adminDeleteOauthApp(appId: id)
  }
}
