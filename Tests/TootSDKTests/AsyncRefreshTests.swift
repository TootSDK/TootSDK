//
//  AsyncRefreshTests.swift
//  TootSDK
//
//  Created by Dale Price on 11/3/2025.
//

import Foundation
import StructuredFieldValues
import XCTest

@testable import TootSDK

final class AsyncRefreshTests: XCTestCase {
    func testDecodeAsyncRefreshHeaderWithoutResultCount() throws {
        let headerContent = "id=\"ImNvbnRleHQ6MTE1NDU4Mzk3NzM5NDE2MzQzOnJlZnJlc2gi--75a626571007cfb13bc09ef3f57bf062547c73dc\", retry=3"
        let decoder = StructuredFieldValueDecoder()

        let result = try decoder.decode(_AsyncRefreshHint.self, from: headerContent.utf8Array)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "ImNvbnRleHQ6MTE1NDU4Mzk3NzM5NDE2MzQzOnJlZnJlc2gi--75a626571007cfb13bc09ef3f57bf062547c73dc")
        XCTAssertEqual(result.retry, 3)
        XCTAssertEqual(result.resultCount, nil)
    }

    func testDecodeAsyncRefreshHeaderWithResultCount() throws {
        let headerContent =
            "id=\"ImNvbnRleHQ6MTE1NDU4Mzk3NzM5NDE2MzQzOnJlZnJlc2gi--75a626571007cfb13bc09ef3f57bf062547c73dc\", retry=3, result_count=10"
        let decoder = StructuredFieldValueDecoder()

        let result = try decoder.decode(_AsyncRefreshHint.self, from: headerContent.utf8Array)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "ImNvbnRleHQ6MTE1NDU4Mzk3NzM5NDE2MzQzOnJlZnJlc2gi--75a626571007cfb13bc09ef3f57bf062547c73dc")
        XCTAssertEqual(result.retry, 3)
        XCTAssertEqual(result.resultCount, 10)
    }

    func testDecodeBlankAsyncRefreshHeader() throws {
        let headerContent = ""
        let decoder = StructuredFieldValueDecoder()

        let result = try? decoder.decode(_AsyncRefreshHint.self, from: headerContent.utf8Array)

        XCTAssertNil(result)
    }

    func testDecodeInvalidAsyncRefreshHeader() throws {
        let headerContent = "id=ImNvbnRleHQ6MT,E1NDU4Mzk3NzM5NDE2MzQzOnJlZnJlc2gi--75a626571007cfb13bc09ef3f57bf062547c73dc"
        let decoder = StructuredFieldValueDecoder()

        let result = try? decoder.decode(_AsyncRefreshHint.self, from: headerContent.utf8Array)

        XCTAssertNil(result)
    }

    func testDecodeAsyncRefreshResponse() throws {
        let json = localContent("mastodon_asyncrefresh_v1_alpha")
        let decoder = TootDecoder()

        let result = try decoder.decode(_AsyncRefreshResponse.self, from: json)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.asyncRefresh.id, "ImNvbnRleHQ6MTE1NDg3MTg3MjM2NzQzNTYwOnJlZnJlc2gi--1f1fb753d84d3570867200cae28afae53e866e3f")
        XCTAssertEqual(result.asyncRefresh.status, .some(.running))
        XCTAssertEqual(result.asyncRefresh.resultCount, 1)
    }
}
