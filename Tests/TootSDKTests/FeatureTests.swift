import XCTest

@testable import TootSDK

final class FeatureTests: XCTestCase {

    func testFeatureChecks() async throws {
        let mastodonClient = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .mastodon)
        )
        let mastodonSupports = await mastodonClient.supportsFeature(.featuredTags)
        XCTAssertTrue(mastodonSupports)
        try await mastodonClient.requireFeature(.featuredTags)

        let akkomaClient = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .akkoma)
        )
        let akkomaSupports = await akkomaClient.supportsFeature(.featuredTags)
        XCTAssertFalse(akkomaSupports)
        do {
            try await akkomaClient.requireFeature(.featuredTags)
            XCTFail("Expected requireFeature to throw for akkoma")
        } catch {
            // expected
        }
    }
}
