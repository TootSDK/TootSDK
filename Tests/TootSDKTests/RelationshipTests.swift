//
//  RelationshipTests.swift
//
//
//  Created by Philip Chu on 8/21/23.
//

import XCTest

@testable import TootSDK

final class RelationshipTests: XCTestCase {

    func testRelationshipDecode() throws {
        // arrange
        let json = localContent("relationship")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(Relationship.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "109580351883608424")
        XCTAssertEqual(result.following, false)
        XCTAssertEqual(result.followedBy, false)
        XCTAssertEqual(result.blocking, false)
        XCTAssertEqual(result.blockedBy, false)
        XCTAssertEqual(result.domainBlocking, false)
        XCTAssertEqual(result.muting, false)
        XCTAssertEqual(result.notifying, false)
        XCTAssertEqual(result.requested, false)
        XCTAssertEqual(result.showingReposts, false)
        XCTAssertEqual(result.endorsed, false)
        XCTAssertEqual(result.note, "")
    }

    func testSharkeyRelationshipDecode() throws {
        let json = localContent("relationship_sharkey")
        let decoder = TootDecoder()

        let result = try decoder.decode(Relationship.self, from: json)

        XCTAssertEqual(result.id, nil)
        XCTAssertEqual(result.following, nil)
        XCTAssertEqual(result.requested, nil)
        XCTAssertEqual(result.endorsed, false)
        XCTAssertEqual(result.followedBy, nil)
        XCTAssertEqual(result.muting, nil)
        XCTAssertEqual(result.mutingNotifications, false)
        XCTAssertEqual(result.showingReposts, true)
        XCTAssertEqual(result.notifying, false)
        XCTAssertEqual(result.blocking, nil)
        XCTAssertEqual(result.domainBlocking, false)
        XCTAssertEqual(result.blockedBy, nil)
        XCTAssertEqual(result.note, nil)
    }
}
