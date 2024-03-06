import ArgumentParser
import Foundation
import TootSDK

struct Logout: AsyncParsableCommand {

    @OptionGroup var auth: AuthOptions

    @Option(
        name: .long,
        help:
            "The client ID, obtained during app registration."
    )
    var clientId: String

    @Option(
        name: .long,
        help:
            "The client secret, obtained during app registration"
    )
    var clientSecret: String

    mutating func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }

        try await client.logout(clientId: clientId, clientSecret: clientSecret)
    }
}
