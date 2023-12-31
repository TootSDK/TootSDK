// Created by konstantin on 10/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation

import XCTest
@testable import TootSDK

final class FlavourTests: XCTestCase {
    func testDetectsMastodon4() throws {
        let instance = try localObject(Instance.self, "mastodon")
        XCTAssertEqual(instance.flavour, .mastodon)
    }
    
    func testDetectsPleroma() throws {
        let instance = try localObject(Instance.self, "pleroma")
        XCTAssertEqual(instance.flavour, .pleroma)
    }
    
    func testDetectsPixelfed() throws {
        let instance = try localObject(Instance.self, "pixelfed")
        XCTAssertEqual(instance.flavour, .pixelfed)
    }
    
    func testDetectsFriendica() throws {
        let instance = try localObject(Instance.self, "instance_friendica_nocontact")
        XCTAssertEqual(instance.flavour, .friendica)
    }
}
