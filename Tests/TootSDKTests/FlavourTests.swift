// Created by konstantin on 10/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import Version
import XCTest

@testable import TootSDK

final class FlavourTests: XCTestCase {
    // MARK: - Instance v1 flavour detection

    func testDetectsMastodon4() throws {
        let instance = try localObject(InstanceV1.self, "mastodon")
        XCTAssertEqual(instance.flavour, .mastodon)
    }

    func testDetectsPleroma() throws {
        let instance = try localObject(InstanceV1.self, "pleroma")
        XCTAssertEqual(instance.flavour, .pleroma)
    }

    func testDetectsPixelfed() throws {
        let instance = try localObject(InstanceV1.self, "pixelfed")
        XCTAssertEqual(instance.flavour, .pixelfed)
    }

    func testDetectsPixelfed12() throws {
        let instance = try localObject(InstanceV1.self, "instance_pixelfed")
        XCTAssertEqual(instance.flavour, .pixelfed)
    }

    func testDetectsFriendica() throws {
        let instance = try localObject(InstanceV1.self, "instance_friendica_nocontact")
        XCTAssertEqual(instance.flavour, .friendica)
    }

    func testDetectsAkkoma() throws {
        let instance = try localObject(InstanceV1.self, "instance_akkoma")
        XCTAssertEqual(instance.flavour, .akkoma)
    }

    func testDetectsFirefish() throws {
        let instance = try localObject(InstanceV1.self, "instance_firefish_contact_removed")
        XCTAssertEqual(instance.flavour, .firefish)
    }

    func testDetectsCatodon() throws {
        let instance = try localObject(InstanceV1.self, "instance_catodon_contact_removed")
        XCTAssertEqual(instance.flavour, .catodon)
    }

    func testDetectsIceshrimp() throws {
        let instance = try localObject(InstanceV1.self, "instance_iceshrimp_contact_removed")
        XCTAssertEqual(instance.flavour, .iceshrimp)
    }

    func testDetectsIceshrimpNet() throws {
        let instance = try localObject(InstanceV1.self, "instance_iceshrimpnet")
        XCTAssertEqual(instance.flavour, .iceshrimp)
    }

    func testDetectsSharkey() throws {
        let instance = try localObject(InstanceV1.self, "instance_sharkey_contact_removed")
        XCTAssertEqual(instance.flavour, .sharkey)
    }

    // MARK: - Instance v2 flavour detection

    func testDetectsV2Mastodon() throws {
        let instance = try localObject(InstanceV2.self, "instancev2_mastodon")
        XCTAssertEqual(instance.flavour, .mastodon)
    }

    func testDetectsV2Firefish() throws {
        let instance = try localObject(InstanceV2.self, "instancev2_firefish")
        XCTAssertEqual(instance.flavour, .firefish)
    }

    func testDetectsV2Friendica() throws {
        let instance = try localObject(InstanceV2.self, "instancev2_friendica")
        XCTAssertEqual(instance.flavour, .friendica)
    }

    func testDetectsV2Pixelfed() throws {
        let instance = try localObject(InstanceV2.self, "instancev2_pixelfed")
        XCTAssertEqual(instance.flavour, .pixelfed)
    }

    func testDetectsV2Pleroma() throws {
        let instance = try localObject(InstanceV2.self, "instancev2_pleroma")
        XCTAssertEqual(instance.flavour, .pleroma)
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

    // MARK: - Version requirement tests

    // MARK: API Version Tests

    func testAPIVersionRequirements() throws {
        // Test basic API version requirement
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 4)
        ])

        // Without API versions - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.4.0"),
                apiVersions: nil
            ))

        // With API version 3 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.3.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 3)
            ))

        // With API version 4 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.4.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 4)
            ))

        // With API version 5 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.5.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 5)
            ))
    }

    func testAPIVersionRangeRequirements() throws {
        // Test API version range requirement
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 3, to: 5)
        ])

        // API version 2 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.2.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 2)
            ))

        // API version 3 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.3.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 3)
            ))

        // API version 5 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.5.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 5)
            ))

        // API version 6 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.6.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 6)
            ))
    }

    func testAPIVersionMaxRequirement() throws {
        // Test maximum API version requirement
        let feature = TootFeature(requirements: [
            .until(.mastodon, version: 3)
        ])

        // API version 2 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.2.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 2)
            ))

        // API version 3 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.3.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 3)
            ))

        // API version 4 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.4.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 4)
            ))
    }

    // MARK: Display Version Tests

    func testDisplayVersionRequirements() throws {
        // Test basic display version requirement
        let feature = TootFeature(requirements: [
            .from(.mastodon, displayVersion: "3.5.0")
        ])

        // Version 3.4.0 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("3.4.0"),
                apiVersions: nil
            ))

        // Version 3.5.0 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("3.5.0"),
                apiVersions: nil
            ))

        // Version 4.0.0 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.0.0"),
                apiVersions: nil
            ))
    }

    func testDisplayVersionRangeRequirements() throws {
        // Test display version range requirement
        let feature = TootFeature(requirements: [
            .from(.pixelfed, displayVersion: "2.0.0", to: "3.0.0")
        ])

        // Version 1.9.0 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .pixelfed,
                version: Version("1.9.0"),
                apiVersions: nil
            ))

        // Version 2.0.0 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .pixelfed,
                version: Version("2.0.0"),
                apiVersions: nil
            ))

        // Version 2.5.0 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .pixelfed,
                version: Version("2.5.0"),
                apiVersions: nil
            ))

        // Version 3.0.0 - should pass (inclusive)
        XCTAssertTrue(
            feature.isSupported(
                flavour: .pixelfed,
                version: Version("3.0.0"),
                apiVersions: nil
            ))

        // Version 3.0.1 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .pixelfed,
                version: Version("3.0.1"),
                apiVersions: nil
            ))
    }

    func testDisplayVersionMaxRequirement() throws {
        // Test maximum display version requirement
        let feature = TootFeature(requirements: [
            .until(.pleroma, displayVersion: "2.5.0")
        ])

        // Version 2.4.0 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .pleroma,
                version: Version("2.4.0"),
                apiVersions: nil
            ))

        // Version 2.5.0 - should pass (inclusive)
        XCTAssertTrue(
            feature.isSupported(
                flavour: .pleroma,
                version: Version("2.5.0"),
                apiVersions: nil
            ))

        // Version 2.6.0 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .pleroma,
                version: Version("2.6.0"),
                apiVersions: nil
            ))
    }

    // MARK: Combined API and Display Version Tests

    func testCombinedAPIAndDisplayVersionFallback() throws {
        // Test feature with API version requirement and display version fallback
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 4, fallbackDisplayVersion: "4.4.0")
        ])

        // With API version 4 - should pass
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.4.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 4)
            ))

        // With API version 3 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.3.0"),
                apiVersions: InstanceV2.APIVersions(mastodon: 3)
            ))

        // Without API version but with display version 4.4.0 - should pass (fallback)
        XCTAssertTrue(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.4.0"),
                apiVersions: nil
            ))

        // Without API version and display version 4.3.0 - should fail
        XCTAssertFalse(
            feature.isSupported(
                flavour: .mastodon,
                version: Version("4.3.0"),
                apiVersions: nil
            ))
    }

    func testDeleteMediaRequiresMastodonAPIVersion() throws {
        // Test with InstanceV1 (no API versions)
        // Since Mastodon supports instanceV2, it won't fall back to display version
        var mastodonBase = try localObject(InstanceV1.self, "mastodon")

        // Even with Mastodon 4.4.0, should fail because no API version is available
        // and Mastodon is expected to provide API versions (supports instanceV2)
        mastodonBase.version = "4.4.0"
        XCTAssertFalse(TootFeature.deleteMedia.isSupported(by: mastodonBase))

        // Test with Mastodon 4.3.0 - should also fail
        mastodonBase.version = "4.3.0"
        XCTAssertFalse(TootFeature.deleteMedia.isSupported(by: mastodonBase))

        // Test with Mastodon 4.5.0 - should also fail (no API version available)
        mastodonBase.version = "4.5.0"
        XCTAssertFalse(TootFeature.deleteMedia.isSupported(by: mastodonBase))

        // Test with pre-release version - should also fail
        mastodonBase.version = "4.4.0-rc1"
        XCTAssertFalse(TootFeature.deleteMedia.isSupported(by: mastodonBase))

        // Even 4.4.1 should fail without API version
        mastodonBase.version = "4.4.1"
        XCTAssertFalse(TootFeature.deleteMedia.isSupported(by: mastodonBase))
    }

    func testDeleteMediaWithApiVersions() throws {
        // Test with InstanceV2 that has API versions
        let instanceV2 = try localObject(InstanceV2.self, "instancev2_mastodon")

        // The test instance has API version 2, which is less than required 4
        XCTAssertFalse(
            TootFeature.deleteMedia.isSupported(
                flavour: instanceV2.flavour,
                version: TootFeature.parseVersion(from: instanceV2.version),
                apiVersions: instanceV2.apiVersions
            ))

        // Test with API version 4 - should pass
        let apiV4 = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertTrue(
            TootFeature.deleteMedia.isSupported(
                flavour: .mastodon,
                version: Version(tolerant: "4.4.0"),
                apiVersions: apiV4
            ))

        // Test with API version 5 - should pass
        let apiV5 = InstanceV2.APIVersions(mastodon: 5)
        XCTAssertTrue(
            TootFeature.deleteMedia.isSupported(
                flavour: .mastodon,
                version: Version(tolerant: "4.5.0"),
                apiVersions: apiV5
            ))

        // Test with API version 3 - should fail
        let apiV3 = InstanceV2.APIVersions(mastodon: 3)
        XCTAssertFalse(
            TootFeature.deleteMedia.isSupported(
                flavour: .mastodon,
                version: Version(tolerant: "4.3.0"),
                apiVersions: apiV3
            ))
    }

    func testDeleteMediaNotSupportedOnOtherFlavours() throws {
        // Load a real Pleroma instance to test - should fail even with high version
        let pleromaInstance = try localObject(InstanceV1.self, "pleroma")
        XCTAssertFalse(TootFeature.deleteMedia.isSupported(by: pleromaInstance))

        // Load a real Pixelfed instance - should also fail
        let pixelfedInstance = try localObject(InstanceV1.self, "pixelfed")
        XCTAssertFalse(TootFeature.deleteMedia.isSupported(by: pixelfedInstance))
    }

    func testFallbackBehaviorForNonInstanceV2Flavours() throws {
        // Test that flavours that don't support instanceV2 still use display version fallback
        // Create a hypothetical feature that supports Akkoma with API version requirement
        let testFeature = TootFeature(requirements: [
            .from(.akkoma, version: 2, fallbackDisplayVersion: "3.0.0")
        ])

        // Note: The test instance file might not be detected as Akkoma flavour
        // but we can still test the fallback behavior by calling the method directly

        // Set version to 3.0.0 - should pass via display version fallback
        let result1 = testFeature.isSupported(
            flavour: .akkoma,
            version: TootFeature.parseVersion(from: "3.0.0"),
            apiVersions: nil
        )
        XCTAssertTrue(result1, "Version 3.0.0 should be supported via display version fallback")

        // Set version to 2.9.0 - should fail
        let result2 = testFeature.isSupported(
            flavour: .akkoma,
            version: TootFeature.parseVersion(from: "2.9.0"),
            apiVersions: nil
        )
        XCTAssertFalse(result2, "Version 2.9.0 should not be supported")

        // Set version to 3.1.0 - should pass
        let result3 = testFeature.isSupported(
            flavour: .akkoma,
            version: TootFeature.parseVersion(from: "3.1.0"),
            apiVersions: nil
        )
        XCTAssertTrue(result3, "Version 3.1.0 should be supported via display version fallback")
    }

    func testBackwardCompatibilityWithoutVersion() throws {
        // Test existing features without version requirements still work
        let feature = TootFeature(supportedFlavours: [.mastodon, .pleroma])

        let mastodonInstance = try localObject(InstanceV1.self, "mastodon")
        XCTAssertTrue(feature.isSupported(by: mastodonInstance))

        let pleromaInstance = try localObject(InstanceV1.self, "pleroma")
        XCTAssertTrue(feature.isSupported(by: pleromaInstance))

        let pixelfedInstance = try localObject(InstanceV1.self, "pixelfed")
        XCTAssertFalse(feature.isSupported(by: pixelfedInstance))
    }

    // MARK: - "All Except" Pattern Tests

    func testUploadMediaAllExceptPattern() throws {
        // Test feature: supported on all servers, but Mastodon requires 3.0+
        // This demonstrates the "allExcept" pattern
        let feature = TootFeature(allExcept: [
            .from(.mastodon, displayVersion: "3.0.0")
        ])

        // Test with Mastodon - needs version 3.0+
        var mastodonBase = try localObject(InstanceV1.self, "mastodon")

        // Mastodon 3.0.0 - should pass
        mastodonBase.version = "3.0.0"
        XCTAssertTrue(feature.isSupported(by: mastodonBase))

        // Mastodon 2.9.0 - should fail
        mastodonBase.version = "2.9.0"
        XCTAssertFalse(feature.isSupported(by: mastodonBase))

        // Mastodon 4.0.0 - should pass
        mastodonBase.version = "4.0.0"
        XCTAssertTrue(feature.isSupported(by: mastodonBase))

        // Test other flavours - should all support any version
        let pleromaInstance = try localObject(InstanceV1.self, "pleroma")
        XCTAssertTrue(feature.isSupported(by: pleromaInstance))

        let pixelfedInstance = try localObject(InstanceV1.self, "pixelfed")
        XCTAssertTrue(feature.isSupported(by: pixelfedInstance))

        let friendicaInstance = try localObject(InstanceV1.self, "instance_friendica_nocontact")
        XCTAssertTrue(feature.isSupported(by: friendicaInstance))

        let akkomaInstance = try localObject(InstanceV1.self, "instance_akkoma")
        XCTAssertTrue(feature.isSupported(by: akkomaInstance))
    }

    // MARK: - "Any Version" Pattern Tests

    func testGetMediaAttachmentAnyVersionPattern() throws {
        // Test feature: available on specific servers with various requirements
        // This demonstrates the "anyVersion" pattern
        let feature = TootFeature(
            anyVersion: [.pleroma, .akkoma, .friendica],  // These support any version
            requirements: [
                .from(.mastodon, displayVersion: "3.1.0"),  // Mastodon needs 3.1+
                .from(.pixelfed, displayVersion: "2.0.0"),  // Pixelfed compatibility version needs 2.0+
            ]
        )

        // Test Pleroma - supports any version (in anyVersion list)
        let pleromaInstance = try localObject(InstanceV1.self, "pleroma")
        XCTAssertTrue(feature.isSupported(by: pleromaInstance))

        // Test Akkoma - supports any version (in anyVersion list)
        let akkomaInstance = try localObject(InstanceV1.self, "instance_akkoma")
        XCTAssertTrue(feature.isSupported(by: akkomaInstance))

        // Test Friendica - supports any version (in anyVersion list)
        let friendicaInstance = try localObject(InstanceV1.self, "instance_friendica_nocontact")
        XCTAssertTrue(feature.isSupported(by: friendicaInstance))

        // Test Mastodon - needs 3.1.0+
        var mastodonBase = try localObject(InstanceV1.self, "mastodon")

        mastodonBase.version = "3.1.0"
        XCTAssertTrue(feature.isSupported(by: mastodonBase))

        mastodonBase.version = "3.0.0"
        XCTAssertFalse(feature.isSupported(by: mastodonBase))

        mastodonBase.version = "4.0.0"
        XCTAssertTrue(feature.isSupported(by: mastodonBase))

        // Test Pixelfed - needs 2.0.0+ (Pixelfed reports Mastodon-compatible version)
        let pixelfedInstance = try localObject(InstanceV1.self, "pixelfed")
        // Actual test data has "2.7.2 (compatible; Pixelfed 0.11.4)" which parses as "2.7.2"
        XCTAssertTrue(feature.isSupported(by: pixelfedInstance), "Pixelfed with version \(pixelfedInstance.version) should be supported")

        // Test with modified version - keep Pixelfed identifier for flavour detection
        var pixelfedBase = pixelfedInstance
        pixelfedBase.version = "1.9.0 (compatible; Pixelfed 0.9.0)"
        XCTAssertFalse(feature.isSupported(by: pixelfedBase))

        pixelfedBase.version = "2.0.0 (compatible; Pixelfed 0.10.0)"
        XCTAssertTrue(feature.isSupported(by: pixelfedBase))

        // Test unsupported flavours (not in anyExcept list and not in versionRequirements)
        let firefishInstance = try localObject(InstanceV1.self, "instance_firefish_contact_removed")
        XCTAssertFalse(feature.isSupported(by: firefishInstance))

        let sharkeyInstance = try localObject(InstanceV1.self, "instance_sharkey_contact_removed")
        XCTAssertFalse(feature.isSupported(by: sharkeyInstance))
    }

    func testFeatureWithNoVersionRequirements() throws {
        // Test a feature that supports specific flavours without any version requirements
        let feature = TootFeature(requirements: [
            .any(.mastodon),
            .any(.pleroma),
            .any(.pixelfed),
        ])

        // All these should work regardless of version
        let mastodonInstance = try localObject(InstanceV1.self, "mastodon")
        XCTAssertTrue(feature.isSupported(by: mastodonInstance))

        let pleromaInstance = try localObject(InstanceV1.self, "pleroma")
        XCTAssertTrue(feature.isSupported(by: pleromaInstance))

        let pixelfedInstance = try localObject(InstanceV1.self, "pixelfed")
        XCTAssertTrue(feature.isSupported(by: pixelfedInstance))

        // This should not work
        let friendicaInstance = try localObject(InstanceV1.self, "instance_friendica_nocontact")
        XCTAssertFalse(feature.isSupported(by: friendicaInstance))
    }

    func testFeatureWithMixedRequirements() throws {
        // Test a feature with mixed requirements - some with versions, some without
        let feature = TootFeature(requirements: [
            .any(.pleroma),  // Any version of Pleroma
            .from(.mastodon, displayVersion: "3.5.0"),  // Mastodon 3.5+
            .from(.pixelfed, displayVersion: "2.0.0", to: "3.0.0"),  // Pixelfed 2.0 to 3.0 (inclusive)
        ])

        // Pleroma should work with any version
        let pleromaInstance = try localObject(InstanceV1.self, "pleroma")
        XCTAssertTrue(feature.isSupported(by: pleromaInstance))

        // Mastodon tests
        var mastodonBase = try localObject(InstanceV1.self, "mastodon")
        mastodonBase.version = "3.5.0"
        XCTAssertTrue(feature.isSupported(by: mastodonBase))

        mastodonBase.version = "3.4.0"
        XCTAssertFalse(feature.isSupported(by: mastodonBase))

        mastodonBase.version = "4.0.0"
        XCTAssertTrue(feature.isSupported(by: mastodonBase))

        // Pixelfed tests (uses Mastodon-compatible version numbers)
        let pixelfedInstance = try localObject(InstanceV1.self, "pixelfed")
        // Test data has "2.7.2 (compatible; Pixelfed 0.11.4)" which our regex extracts as "2.7.2"
        // This is within 2.0 to <3.0 range
        XCTAssertTrue(feature.isSupported(by: pixelfedInstance))

        var pixelfedBase = pixelfedInstance
        // Keep Pixelfed identifier in version string for flavour detection
        pixelfedBase.version = "2.0.0 (compatible; Pixelfed 0.10.0)"
        XCTAssertTrue(feature.isSupported(by: pixelfedBase))

        pixelfedBase.version = "2.9.9 (compatible; Pixelfed 0.11.0)"
        XCTAssertTrue(feature.isSupported(by: pixelfedBase))

        pixelfedBase.version = "3.0.0 (compatible; Pixelfed 0.12.0)"
        XCTAssertTrue(feature.isSupported(by: pixelfedBase), "3.0.0 should be included (max is inclusive)")

        pixelfedBase.version = "3.0.1 (compatible; Pixelfed 0.12.1)"
        XCTAssertFalse(feature.isSupported(by: pixelfedBase), "3.0.1 should be excluded (greater than max)")

        pixelfedBase.version = "1.9.0 (compatible; Pixelfed 0.9.0)"
        XCTAssertFalse(feature.isSupported(by: pixelfedBase))
    }
}
