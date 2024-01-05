import ArgumentParser
import Foundation
import TootSDK

struct ListAllNotifications: AsyncParsableCommand {

    @OptionGroup var auth: AuthOptions
    @Option var types: [TootNotification.NotificationType] = [.mention]
    @Option var excludeTypes: [TootNotification.NotificationType] = []

    mutating func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)

        var pagedInfo: PagedInfo? = nil
        var hasMore = true
        let query = TootNotificationParams(excludeTypes: excludeTypes, types: types)

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

extension TootNotification.NotificationType: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument)
    }
}
