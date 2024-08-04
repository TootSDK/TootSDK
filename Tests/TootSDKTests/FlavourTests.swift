// Created by konstantin on 10/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import XCTest

@testable import TootSDK

final class FlavourTests: XCTestCase {
    // MARK: - Instance flavour detection

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

    func testDetectsAkkoma() throws {
        let instance = try localObject(Instance.self, "instance_akkoma")
        XCTAssertEqual(instance.flavour, .akkoma)
    }

    func testDetectsFirefish() throws {
        let instance = try localObject(Instance.self, "instance_firefish_contact_removed")
        XCTAssertEqual(instance.flavour, .firefish)
    }

    func testDetectsCatodon() throws {
        let instance = try localObject(Instance.self, "instance_catodon_contact_removed")
        XCTAssertEqual(instance.flavour, .catodon)
    }

    func testDetectsIceshrimp() throws {
        let instance = try localObject(Instance.self, "instance_iceshrimp_contact_removed")
        XCTAssertEqual(instance.flavour, .iceshrimp)
    }

    func testDetectsIceshrimpNet() throws {
        let instance = try localObject(Instance.self, "instance_iceshrimpnet")
        XCTAssertEqual(instance.flavour, .iceshrimp)
    }

    func testDetectsSharkey() throws {
        let instance = try localObject(Instance.self, "instance_sharkey_contact_removed")
        XCTAssertEqual(instance.flavour, .sharkey)
    }

    // MARK: - NodeInfo flavour detection

    func testDetectsNodeInfoAkkoma() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_akkoma")
        XCTAssertEqual(nodeInfo.flavour, .akkoma)
    }

    func testDetectsNodeInfoCatodon() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_catodon")
        XCTAssertEqual(nodeInfo.flavour, .catodon)
    }

    func testDetectsNodeInfoFirefish() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_firefish")
        XCTAssertEqual(nodeInfo.flavour, .firefish)
    }

    func testDetectsNodeInfoFriendica() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_friendica")
        XCTAssertEqual(nodeInfo.flavour, .friendica)
    }

    func testDetectsNodeInfoIceshrimp() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_iceshrimp")
        XCTAssertEqual(nodeInfo.flavour, .iceshrimp)
    }

    func testDetectsNodeInfoIceshrimpNet() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_iceshrimpnet")
        XCTAssertEqual(nodeInfo.flavour, .iceshrimp)
    }

    func testDetectsNodeInfoMastodon() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_mastodon")
        XCTAssertEqual(nodeInfo.flavour, .mastodon)
    }

    func testDetectsNodeInfoPixelfed() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_pixelfed")
        XCTAssertEqual(nodeInfo.flavour, .pixelfed)
    }

    func testDetectsNodeInfoPleroma() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_pleroma")
        XCTAssertEqual(nodeInfo.flavour, .pleroma)
    }

    func testDetectsNodeInfoSharkey() throws {
        let nodeInfo = try localObject(NodeInfo.self, "nodeinfo_sharkey")
        XCTAssertEqual(nodeInfo.flavour, .sharkey)
    }

    func testDetectsNodeInfoGoToSocial() throws {
        let instance = try localObject(NodeInfo.self, "nodeinfo_gotosocial")
        XCTAssertEqual(instance.flavour, .goToSocial)
    }
}
