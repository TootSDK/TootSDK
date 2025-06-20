// Created by konstantin on 23/04/2024.

import XCTest

@testable import TootSDK

final class PostTests: XCTestCase {

    func testPostEdited() throws {
        // arrange
        let json = localContent("post_edited")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(Post.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "112300188527054704")
        XCTAssertEqual(result.filtered, [])
        XCTAssertEqual(result.mentions, [])
        XCTAssertEqual(result.emojis, [])
        XCTAssertEqual(result.mediaAttachments, [])
        XCTAssertEqual(result.tags.count, 1)
        XCTAssertEqual(result.favourited, false)
        XCTAssertEqual(result.reposted, false)
        XCTAssertNotNil(result.createdAt)

        // let's test if the date was correctly parsed
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = DateComponents(year: 2024, month: 04, day: 19, hour: 22, minute: 15, second: 22)
        let expectedDate = calendar.date(from: components)!
        XCTAssertNotNil(result.editedAt)
        XCTAssertEqual(result.editedAt!.timeIntervalSince1970, expectedDate.timeIntervalSince1970)

        XCTAssertNil(result.inReplyToId)
        XCTAssertFalse(result.sensitive)
        XCTAssertNotNil(result.content)
        XCTAssertNil(result.poll)
        XCTAssertNotNil(result.card)
        XCTAssertNotNil(result.url)
        XCTAssertEqual(result.spoilerText, "")
        XCTAssertEqual(result.language, "en")
        XCTAssertEqual(result.visibility, .some(.public))
        XCTAssertEqual(result.pinned, false)
        XCTAssertEqual(result.muted, false)
        XCTAssertEqual(result.favouritesCount, 1)
        XCTAssertEqual(result.repliesCount, 1)
        XCTAssertEqual(result.bookmarked, true)
    }
}
