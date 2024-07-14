//
//  HTMLRenderingTests.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 14/07/2024.
//

import XCTest
import TootSDK

final class HTMLRenderingTests: XCTestCase {

    func testExtractAsPlainText() throws {
        let html = "<p>Hello, World!</p>"
        let plain = TootHTML.extractAsPlainText(html: html)
        XCTAssertEqual(plain, "Hello, World!")
    }

    func testMultipleParagraphs() throws {
        let html = "<p>Hello, World!</p><p>Second paragraph</p>"
        let plain = TootHTML.extractAsPlainText(html: html)
        XCTAssertEqual(plain, "Hello, World!\nSecond paragraph")
    }

    func testLineBreaks() throws {
        let html = "<p>Hello, World!<br>with<br />Line breaks</p>"
        let plain = TootHTML.extractAsPlainText(html: html)
        XCTAssertEqual(plain, "Hello, World!\nwith\nLine breaks")
    }
}
