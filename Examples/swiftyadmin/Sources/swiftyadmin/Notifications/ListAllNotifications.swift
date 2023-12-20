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
