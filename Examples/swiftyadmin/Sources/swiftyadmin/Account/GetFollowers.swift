import ArgumentParser
import Foundation
import TootSDK

struct GetFollowers: AsyncParsableCommand {
  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with sufficient permissions.")
  var token: String

  mutating func run() async throws {
    let client = try await TootClient(connect: URL(string: url)!, accessToken: token)
    let account = try await client.verifyCredentials()

    var pagedInfo: PagedInfo? = nil
    var hasMore = true

    while hasMore {
      let page = try await client.getFollowers(for: account.id, pagedInfo)
      for follower in page.result {
        print(follower.acct)
      }
      hasMore = page.hasPrevious
      pagedInfo = page.previousPage
    }
  }
}
