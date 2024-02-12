//
//  ListTests.swift
//
//
//  Created by Philip Chu on 8/18/23.
//

import XCTest

@testable import TootSDK

final class ListTests: XCTestCase {

    func testListDecode() throws {
        // arrange
        let json = localContent("list")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(List.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "3309")
        XCTAssertEqual(result.title, "tech")
        XCTAssertEqual(result.repliesPolicy, .followed)
    }

}
