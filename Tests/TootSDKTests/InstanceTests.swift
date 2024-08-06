import XCTest

@testable import TootSDK

final class InstanceTests: XCTestCase {
    func testFriendicaNoContact() throws {
        // arrange
        let json = localContent("instance_friendica_nocontact")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(Instance.self, from: json)

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
        let result = try decoder.decode(Instance.self, from: json)

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
}
