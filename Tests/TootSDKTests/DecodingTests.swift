//
//  DecodingTests.swift
//
//
//  Created by Łukasz Rutkowski on 18/03/2023.
//

import XCTest

@testable import TootSDK

final class DecodingTests: XCTestCase {

    func testDecodeIntFromString() throws {
        try assertDecodes(#"{"int": 2}"#, as: Element(2))
        try assertDecodes(#"{"int": "5"}"#, as: Element(5))
        try assertDecodes(#"{"int": -12}"#, as: Element(-12))
        try assertDecodes(#"{"int": "-7"}"#, as: Element(-7))
    }

    private func assertDecodes(_ json: String, as element: Element) throws {
        let decoder = JSONDecoder()
        let data = Data(json.utf8)
        let decodedElement = try decoder.decode(Element.self, from: data)
        XCTAssertEqual(decodedElement, element)
    }

    struct Element: Decodable, Equatable {
        let int: Int

        init(_ int: Int) {
            self.int = int
        }

        enum CodingKeys: CodingKey {
            case int
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.int = try container.decodeIntFromString(forKey: .int)
        }
    }
}
