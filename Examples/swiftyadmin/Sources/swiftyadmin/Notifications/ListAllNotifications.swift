import ArgumentParser
import Foundation
import TootSDK

struct ListAllNotifications: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Access token for an account with sufficient permissions.")
  var token: String

  mutating func run() async throws {
    let client = try await TootClient(connect: URL(string: url)!, accessToken: token)

    var pagedInfo: PagedInfo? = nil
    var hasMore = true
    let query = TootNotificationParams(types: [.mention])

    while hasMore {
      let page = try await client.getNotifications(params: query, pagedInfo)
      print("=== page ===")
      print(
        """
        hasPrevious: \(page.hasPrevious)
        hasNext: \(page.hasNext)
        maxID: \(page.info.maxId ?? "nil")
        maxID: \(page.previousPage?.maxId ?? "nil")
        minId: \(page.info.minId ?? "nil")
        minId: \(page.previousPage?.minId ?? "nil")
        sinceId: \(page.info.sinceId ?? "nil")
        sinceId: \(page.previousPage?.sinceId ?? "nil")
        """)
      for notification in page.result {
        print(
          notification.id + ", " + notification.type.rawValue + ", "
            + notification.createdAt.formatted())
      }
      hasMore = page.hasPrevious
      pagedInfo = page.previousPage
    }

  }
}
