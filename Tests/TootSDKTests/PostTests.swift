// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.

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
        XCTAssertNotNil(result.editedAt)
        XCTAssertNil(result.inReplyToId)
        XCTAssertFalse(result.sensitive)
        XCTAssertNotNil(result.content)
        XCTAssertNil(result.poll)
        XCTAssertNotNil(result.card)
        XCTAssertNotNil(result.url)
        XCTAssertEqual(result.spoilerText, "")
        XCTAssertEqual(result.language, "en")
        XCTAssertEqual(result.visibility, .public)
        XCTAssertEqual(result.pinned, false)
        XCTAssertEqual(result.muted, false)
        XCTAssertEqual(result.favouritesCount, 1)
        XCTAssertEqual(result.repliesCount, 1)
        XCTAssertEqual(result.bookmarked, true)
    }
}
