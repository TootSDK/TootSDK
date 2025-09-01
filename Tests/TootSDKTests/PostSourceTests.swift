//
//  Test.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 10/08/2025.
//

import Testing

@testable import TootSDK

struct PostSourceTests {

    @Test func mastodonPostSource() async throws {
        // arrange
        let json = localContent("post_source_mastodon")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(PostSource.self, from: json)

        // assert
        #expect(result.id == "1234")
        #expect(result.text == "Test")
        #expect(result.spoilerText == "")
    }

    @Test func pleromaPostSource() async throws {
        // arrange
        let json = localContent("post_source_pleroma")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(PostSource.self, from: json)

        // assert
        #expect(result.id == "1234")
        #expect(result.text == "Test, *markdown*")
        #expect(result.spoilerText == "")
        #expect(result.contentType == "text/markdown")
    }
}
