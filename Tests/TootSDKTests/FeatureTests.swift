import XCTest

@testable import TootSDK

final class FeatureTests: XCTestCase {

    func testFeatureChecks() throws {
        let mastodonClient = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .mastodon)
        )
        XCTAssertTrue(mastodonClient.supportsFeature(.featuredTags))
        XCTAssertNoThrow(try mastodonClient.requireFeature(.featuredTags))

        let akkomaClient = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .akkoma)
        )
        XCTAssertFalse(akkomaClient.supportsFeature(.featuredTags))
        XCTAssertThrowsError(try akkomaClient.requireFeature(.featuredTags))
    }
}
