import XCTest
@testable import TootSDK

final class FeatureTests: XCTestCase {

    func testFeatureChecks() throws {
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)

        client.flavour = .mastodon
        XCTAssertTrue(client.supportsFeature(.featuredTags))
        XCTAssertNoThrow(try client.requireFeature(.featuredTags))

        client.flavour = .akkoma
        XCTAssertFalse(client.supportsFeature(.featuredTags))
        XCTAssertThrowsError(try client.requireFeature(.featuredTags))
    }
}
