import ArgumentParser
import Foundation
import TootSDK

struct ListOauthApps: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with the admin:write claim")
    var token: String

    @Option(name: .short, help: "Filter by app name")
    var name: String = ""

    @Option(name: .short, help: "Filter by client id")
    var clientId: String = ""

    @Option(name: .long, help: "Filter by trusted true or false")
    var trusted: String = ""

    mutating func run() async throws {
        print("Listing OAuth apps:")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let params = ListOauthAppsParams(
            name: name != "" ? name : nil, clientId: clientId != "" ? clientId : nil,
            trusted: trusted != "" ? Bool(trusted) : nil)
        var loadNext: Bool = true
        var page: Int = 1
        while loadNext {
            if let results = try await client.adminGetOauthApps(page, params: params) {
                for app in results {
                    print(
                        "id: \(app.id)\n" + "\t\(app.name ?? "-")\n"
                            + "\tredirectUri: \(app.redirectUri ?? "-")\n"
                            + "\twebsite:\(app.website ?? "-")\n"
                            + "\tclientId: \(app.clientId ?? "-")\n"
                            + "\tclientSecret: \(app.clientSecret ?? "-")"
                    )
                }
                page += 1
                loadNext = results.count > 0
            } else {
                print("No apps found")
                loadNext = false
            }
        }
    }
}
