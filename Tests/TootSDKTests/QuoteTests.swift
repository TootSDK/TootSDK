//
//  QuoteTests.swift
//  TootSDK
//
//  Created by Dale Price on 7/17/25.
//

import XCTest

@testable import TootSDK

final class QuoteTests: XCTestCase {
    func testQuote() throws {
        // arrange
        let json = localContent("quote")
        let decoder = TootDecoder()

        // act
        let result: Quote = try decoder.decode(Quote.self, from: json)

        // assert
        XCTAssertEqual(result.state.value, Quote.QuoteState.accepted)
        XCTAssertNotNil(result.quotedPost)
        if case let .post(quotedPost) = result.quotedPost {
            XCTAssertEqual(quotedPost.id, "103270115826048975")
        } else {
            XCTFail("quotedPost should be a .post")
        }
    }

    func testShallowQuote() throws {
        // arrange
        let json = localContent("shallow_quote")
        let decoder = TootDecoder()

        // act
        let result: Quote = try decoder.decode(Quote.self, from: json)

        // assert
        XCTAssertEqual(result.state.value, Quote.QuoteState.accepted)
        XCTAssertNotNil(result.quotedPost)
        if case let .postID(quotedPostID) = result.quotedPost {
            XCTAssertEqual(quotedPostID, "103270115826048975")
        } else {
            XCTFail("quotedPost should be a .postID")
        }
    }
}
