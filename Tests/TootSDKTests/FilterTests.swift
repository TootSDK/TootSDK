//
//  FilterTests.swift
//
//
//  Created by Łukasz Rutkowski on 02/07/2024.
//

import XCTest

@testable import TootSDK

final class FilterTests: XCTestCase {

    func testQueryItemsWhenUpdatingFilter() throws {
        let params = UpdateFilterParams(
            id: "1",
            title: "Filter",
            context: [.home],
            action: .hide,
            expiry: .seconds(8),
            keywords: [
                .create(keyword: "word", wholeWord: true),
                .update(id: "7", keyword: "name"),
                .delete(id: "5"),
                .create(keyword: "new", wholeWord: false),
            ]
        )
        XCTAssertEqual(
            params.queryItems,
            [
                URLQueryItem(name: "title", value: "Filter"),
                URLQueryItem(name: "context[]", value: "home"),
                URLQueryItem(name: "filter_action", value: "hide"),
                URLQueryItem(name: "expires_in", value: "8"),
                URLQueryItem(name: "keywords_attributes[][id]", value: ""),
                URLQueryItem(name: "keywords_attributes[][keyword]", value: "word"),
                URLQueryItem(name: "keywords_attributes[][whole_word]", value: "true"),
                URLQueryItem(name: "keywords_attributes[][id]", value: "7"),
                URLQueryItem(name: "keywords_attributes[][keyword]", value: "name"),
                URLQueryItem(name: "keywords_attributes[][id]", value: "5"),
                URLQueryItem(name: "keywords_attributes[][_destroy]", value: "true"),
                URLQueryItem(name: "keywords_attributes[][id]", value: ""),
                URLQueryItem(name: "keywords_attributes[][keyword]", value: "new"),
                URLQueryItem(name: "keywords_attributes[][whole_word]", value: "false"),
            ])
    }

    func testQueryItemsWhenCreatingFilter() throws {
        let params = CreateFilterParams(
            title: "Filter",
            context: [.account],
            action: .warn,
            expiresInSeconds: 9,
            keywords: [
                .init(keyword: "word", wholeWord: false)
            ]
        )
        XCTAssertEqual(
            params.queryItems,
            [
                URLQueryItem(name: "title", value: "Filter"),
                URLQueryItem(name: "filter_action", value: "warn"),
                URLQueryItem(name: "context[]", value: "account"),
                URLQueryItem(name: "expires_in", value: "9"),
                URLQueryItem(name: "keywords_attributes[][keyword]", value: "word"),
                URLQueryItem(name: "keywords_attributes[][whole_word]", value: "false"),
            ])
    }

    func testQueryItemsWhenCreatingFilterWithLessData() throws {
        let params = CreateFilterParams(
            title: "Filter",
            context: [],
            action: .warn,
            expiresInSeconds: nil,
            keywords: []
        )
        XCTAssertEqual(
            params.queryItems,
            [
                URLQueryItem(name: "title", value: "Filter"),
                URLQueryItem(name: "filter_action", value: "warn"),
            ])
    }
}
