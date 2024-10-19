import XCTest

@testable import TootSDK

final class InstanceTests: XCTestCase {
    func testFriendicaNoContact() throws {
        // arrange
        let json = localContent("instance_friendica_nocontact")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV1.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertNil(result.contactAccount)
        XCTAssertEqual(result.languages, ["fr"])
        XCTAssertEqual(result.version, "2.8.0 (compatible; Friendica 2023.05)")
        XCTAssertEqual(result.uri, "social.thisworksonmycomputer.local")
        XCTAssertEqual(result.title, "Social")
        XCTAssertEqual(result.invitesEnabled, false)
        XCTAssertEqual(result.registrations, true)
    }

    func testPixelfed12CountsAreStringsWeHandleGracefully() throws {
        // arrange
        let json = localContent("instance_pixelfed")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV1.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, ["en"])
        XCTAssertEqual(result.version, "3.5.3 (compatible; Pixelfed 0.12.3)")
        XCTAssertEqual(result.uri, "pixelfed.social")
        XCTAssertEqual(result.title, "pixelfed")
        XCTAssertEqual(result.registrations, true)
        XCTAssertEqual(result.stats.domainCount, 26576)
        XCTAssertEqual(result.stats.userCount, 119267)
        XCTAssertEqual(result.stats.postCount, 29_662_653)
    }

    func testMastodonV2() throws {
        // arrange
        let json = localContent("instancev2_mastodon")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV2.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, ["en"])
        XCTAssertEqual(result.version, "4.3.0+pr-32577-ba659d5")
        XCTAssertEqual(result.domain, "mastodon.social")
        XCTAssertEqual(result.title, "Mastodon")
        XCTAssertEqual(result.sourceURL, "https://github.com/mastodon/mastodon")
        XCTAssertEqual(result.registrations.enabled, true)
        XCTAssertEqual(result.usage.users.activeMonth, 234394)
        XCTAssertEqual(result.configuration?.accounts?.maxFeaturedTags, 10)
        XCTAssertEqual(result.configuration?.accounts?.maxPinnedPosts, 5)
        XCTAssertEqual(result.icon?.count, 9)
        XCTAssertEqual(result.thumbnail.blurhash, "UeKUpFxuo~R%0nW;WCnhF6RjaJt757oJodS$")
        XCTAssertEqual(result.thumbnail.versions?.at2x, "https://files.mastodon.social/site_uploads/files/000/000/001/@2x/57c12f441d083cde.png")
        XCTAssertEqual(result.apiVersions?.mastodon, 2)
        XCTAssertEqual(
            result.configuration?.vapid?.publicKey, "BCk-QqERU0q-CfYZjcuB6lnyyOYfJ2AifKqfeGIm7Z-HiTU5T9eTG5GxVA0_OH5mMlI4UkkDTpaZwozy0TzdZ2M=")
        XCTAssertEqual(result.configuration?.translation?.enabled, true)
    }
}
