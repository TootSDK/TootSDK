//
//  PostTranslationTests.swift
//
//
//  Created by Philip Chu on 2/10/24.
//

import XCTest

@testable import TootSDK

final class PostTranslationTests: XCTestCase {

    func testTranslatedPostPoll() throws {
        // arrange
        let json = localContent("translation_poll")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(Translation.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.detectedSourceLanguage, "es")
        XCTAssertEqual(result.provider, "LibreTranslate")
        XCTAssertNotNil(result.poll)
        XCTAssertEqual(result.poll!.id, "255331")
        XCTAssertEqual(result.poll!.options[0].title, "One")
        XCTAssertEqual(result.poll!.options[1].title, "Two.")
        XCTAssertEqual(result.poll!.options[2].title, "Three.")
    }

    func testTranslatedPostAttachment() throws {
        // arrange
        let json = localContent("translation_attachment")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(Translation.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.detectedSourceLanguage, "de")
        XCTAssertEqual(result.provider, "DeepL.com")
        XCTAssertNil(result.poll)
        XCTAssertEqual(result.mediaAttachments[0].description, "three cats")
    }
}
