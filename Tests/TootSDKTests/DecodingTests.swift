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

    func testDecodeIfPresentIntFromString() throws {
        try assertDecodes(#"{"int": 2}"#, as: OptionalElement(2))
        try assertDecodes(#"{"int": "5"}"#, as: OptionalElement(5))
        try assertDecodes(#"{"int": -12}"#, as: OptionalElement(-12))
        try assertDecodes(#"{"int": "-7"}"#, as: OptionalElement(-7))
        try assertDecodes(#"{"int": null}"#, as: OptionalElement(nil))
        try assertDecodes(#"{}"#, as: OptionalElement(nil))
    }

    func testDecodeOpenEnum() throws {
        try assertDecodes(#""blur""#, as: Filter.Action.blur)
        try assertDecodes(#""blur""#, as: OpenEnum<Filter.Action>.some(.blur))
        XCTAssertThrowsError(try decode(#""obfuscate""#, as: Filter.Action.self))
        try assertDecodes(#""obfuscate""#, as: OpenEnum<Filter.Action>.unparsedByTootSDK(rawValue: "obfuscate"))
    }

    func testDecodeOpenEnumAsDictionaryKey() throws {
        try assertDecodes(#"{"home": true}"#, as: [Marker.Timeline.home: true])
        try assertDecodes(#"{"home": true}"#, as: [OpenEnum<Marker.Timeline>.some(.home): true])
        XCTAssertThrowsError(try decode(#"{"garden": false}"#, as: [Marker.Timeline: Bool].self))
        try assertDecodes(#"{"garden": false}"#, as: [OpenEnum<Marker.Timeline>.unparsedByTootSDK(rawValue: "garden"): false])
    }

    private func assertDecodes<T: Equatable & Decodable>(_ json: String, as element: T) throws {
        let decodedElement = try decode(json, as: T.self)
        XCTAssertEqual(decodedElement, element)
    }

    private func decode<T: Equatable & Decodable>(_ json: String, as: T.Type) throws -> T {
        let decoder = JSONDecoder()
        let data = Data(json.utf8)
        return try decoder.decode(T.self, from: data)
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

    struct OptionalElement: Decodable, Equatable {
        let int: Int?

        init(_ int: Int?) {
            self.int = int
        }

        enum CodingKeys: CodingKey {
            case int
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.int = try container.decodeIntFromStringIfPresent(forKey: .int)
        }
    }
}
