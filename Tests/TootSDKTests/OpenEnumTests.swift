//
//  OpenEnumTests.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 19/06/2025.
//

import Testing
import TootSDK

struct OpenEnumTests {

    @Test func rawValue() async throws {
        #expect(OpenEnum<Filter.Action>.some(.blur).rawValue == "blur")
        #expect(OpenEnum<Filter.Action>.unparsedByTootSDK(rawValue: "obfuscate").rawValue == "obfuscate")
    }

    @Test func value() async throws {
        #expect(OpenEnum<Filter.Action>.some(.blur).value == Filter.Action.blur)
        #expect(OpenEnum<Filter.Action>.unparsedByTootSDK(rawValue: "obfuscate").value == nil)
    }

    @Test func optional() async throws {
        #expect(OpenEnum<Filter.Action>.optional(.blur) == OpenEnum<Filter.Action>.some(.blur))
        #expect(OpenEnum<Filter.Action>.optional(nil) == nil)
    }
}
