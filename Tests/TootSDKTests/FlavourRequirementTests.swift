// ABOUTME: Tests for FlavourRequirement API and display version checking functionality
// ABOUTME: Verifies ergonomic factory methods and version range support

import Version
import XCTest

@testable import TootSDK

final class FlavourRequirementTests: XCTestCase {

    // MARK: - API Version Tests (Primary/Default)

    func testApiVersionMinimumRequirement() throws {
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 4)
        ])

        // Test with API versions available
        let apiVersions = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions))

        let apiVersionsLower = InstanceV2.APIVersions(mastodon: 3)
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersionsLower))

        let apiVersionsHigher = InstanceV2.APIVersions(mastodon: 5)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersionsHigher))
    }

    func testApiVersionRangeRequirement() throws {
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 3, to: 5)
        ])

        let apiVersions2 = InstanceV2.APIVersions(mastodon: 2)
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions2))

        let apiVersions3 = InstanceV2.APIVersions(mastodon: 3)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions3))

        let apiVersions4 = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions4))

        let apiVersions5 = InstanceV2.APIVersions(mastodon: 5)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions5))

        let apiVersions6 = InstanceV2.APIVersions(mastodon: 6)
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions6))
    }

    func testApiVersionMaximumRequirement() throws {
        let feature = TootFeature(requirements: [
            .until(.mastodon, version: 4)
        ])

        let apiVersions3 = InstanceV2.APIVersions(mastodon: 3)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions3))

        let apiVersions4 = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions4))

        let apiVersions5 = InstanceV2.APIVersions(mastodon: 5)
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions5))
    }

    // MARK: - Display Version Tests (Fallback/Legacy)

    func testDisplayVersionMinimumRequirement() throws {
        let feature = TootFeature(requirements: [
            .from(.mastodon, displayVersion: "4.0.0")
        ])

        let version3 = Version(tolerant: "3.5.0")
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: version3))

        let version4 = Version(tolerant: "4.0.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version4))

        let version41 = Version(tolerant: "4.1.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version41))
    }

    func testDisplayVersionRangeRequirement() throws {
        let feature = TootFeature(requirements: [
            .from(.mastodon, displayVersion: "3.0.0", to: "5.0.0")
        ])

        let version2 = Version(tolerant: "2.9.0")
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: version2))

        let version3 = Version(tolerant: "3.0.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version3))

        let version4 = Version(tolerant: "4.5.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version4))

        let version5 = Version(tolerant: "5.0.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version5))

        let version6 = Version(tolerant: "5.1.0")
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: version6))
    }

    func testDisplayVersionMaximumRequirement() throws {
        let feature = TootFeature(requirements: [
            .until(.mastodon, displayVersion: "4.0.0")
        ])

        let version3 = Version(tolerant: "3.5.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version3))

        let version4 = Version(tolerant: "4.0.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version4))

        let version41 = Version(tolerant: "4.1.0")
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: version41))
    }

    // MARK: - Combined Requirements Tests

    func testApiVersionWithDisplayVersionFallback() throws {
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 4, fallbackDisplayVersion: "4.3.0")
        ])

        // Test with API version available - should use API version check
        let apiVersions4 = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions4))

        let apiVersions3 = InstanceV2.APIVersions(mastodon: 3)
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: apiVersions3))

        // Test without API version - should fall back to display version
        let displayVersion430 = Version(tolerant: "4.3.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: displayVersion430, apiVersions: nil))

        let displayVersion420 = Version(tolerant: "4.2.0")
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: displayVersion420, apiVersions: nil))
    }

    // MARK: - Multiple Flavour Requirements

    func testMultipleFlavourRequirements() throws {
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 4),
            .from(.pleroma, displayVersion: "2.5.0"),
            .any(.akkoma),
        ])

        // Test Mastodon with API version
        let mastodonApiVersions = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: mastodonApiVersions))

        let mastodonApiVersionsOld = InstanceV2.APIVersions(mastodon: 3)
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: mastodonApiVersionsOld))

        // Test Pleroma with display version
        let pleromaVersion = Version(tolerant: "2.5.0")
        XCTAssertTrue(feature.isSupported(flavour: .pleroma, version: pleromaVersion))

        let pleromaVersionOld = Version(tolerant: "2.4.0")
        XCTAssertFalse(feature.isSupported(flavour: .pleroma, version: pleromaVersionOld))

        // Test Akkoma - any version
        XCTAssertTrue(feature.isSupported(flavour: .akkoma, version: nil as Version?))
        XCTAssertTrue(feature.isSupported(flavour: .akkoma, version: Version(tolerant: "1.0.0")))

        // Test unsupported flavour
        XCTAssertFalse(feature.isSupported(flavour: .pixelfed, version: nil as Version?))
    }

    // MARK: - Convenience Initializers

    func testAllExceptInitializer() throws {
        let feature = TootFeature(allExcept: [
            .from(.mastodon, version: 5),
            .from(.pleroma, displayVersion: "3.0.0"),
        ])

        // Mastodon requires API version >= 5
        let mastodonApiVersions4 = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: mastodonApiVersions4))

        let mastodonApiVersions5 = InstanceV2.APIVersions(mastodon: 5)
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil, apiVersions: mastodonApiVersions5))

        // Pleroma requires display version >= 3.0.0
        let pleromaVersion2 = Version(tolerant: "2.9.0")
        XCTAssertFalse(feature.isSupported(flavour: .pleroma, version: pleromaVersion2))

        let pleromaVersion3 = Version(tolerant: "3.0.0")
        XCTAssertTrue(feature.isSupported(flavour: .pleroma, version: pleromaVersion3))

        // Other flavours should work with any version
        XCTAssertTrue(feature.isSupported(flavour: .akkoma, version: nil as Version?))
        XCTAssertTrue(feature.isSupported(flavour: .pixelfed, version: Version(tolerant: "1.0.0")))
    }

    // MARK: - Instance Integration Tests

    func testWithInstanceV2() throws {
        let instance = InstanceV2(
            version: "4.3.0",
            registrations: InstanceV2.Registrations(),
            apiVersions: InstanceV2.APIVersions(mastodon: 4)
        )

        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 4)
        ])

        XCTAssertTrue(feature.isSupported(by: instance))

        let featureRequiringHigherApi = TootFeature(requirements: [
            .from(.mastodon, version: 5)
        ])

        XCTAssertFalse(featureRequiringHigherApi.isSupported(by: instance))
    }

    // MARK: - Edge Cases

    func testNoVersionRequirement() throws {
        let feature = TootFeature(requirements: [
            .any(.mastodon)
        ])

        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil as Version?))
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: Version(tolerant: "1.0.0")))
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil as Version?, apiVersions: nil))
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: nil as Version?, apiVersions: InstanceV2.APIVersions(mastodon: 1)))
    }

    func testVersionParsingFromString() throws {
        let feature = TootFeature(requirements: [
            .from(.mastodon, displayVersion: "4.0.0")
        ])

        // Test with various version string formats
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: "4.0.0"))
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: "4.1.0"))
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: "4.0.0+glitch"))
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: "3.5.0"))
    }

    func testDisplayVersionRange() throws {
        // Test the display version range method
        let feature = TootFeature(requirements: [
            .from(.mastodon, displayVersion: "3.0.0", to: "5.0.0")
        ])

        let version4 = Version(tolerant: "4.0.0")
        XCTAssertTrue(feature.isSupported(flavour: .mastodon, version: version4))

        let version6 = Version(tolerant: "6.0.0")
        XCTAssertFalse(feature.isSupported(flavour: .mastodon, version: version6))
    }

    // MARK: - Cross-Flavour API Version Support

    func testCrossFlavourApiVersionSupport() throws {
        // Test that Akkoma server providing Mastodon API version can satisfy Mastodon API requirements
        let feature = TootFeature(requirements: [
            .from(.mastodon, version: 4)
        ])

        // Akkoma server that reports Mastodon API v6 should satisfy requirements for Mastodon API v4+
        let akkomaApiVersions = InstanceV2.APIVersions(mastodon: 6)
        XCTAssertTrue(feature.isSupported(flavour: .akkoma, version: nil, apiVersions: akkomaApiVersions))

        // Akkoma server with Mastodon API v3 should NOT satisfy requirements for Mastodon API v4+
        let akkomaApiVersionsOld = InstanceV2.APIVersions(mastodon: 3)
        XCTAssertFalse(feature.isSupported(flavour: .akkoma, version: nil, apiVersions: akkomaApiVersionsOld))

        // Pleroma server with Mastodon API support
        let pleromaApiVersions = InstanceV2.APIVersions(mastodon: 5)
        XCTAssertTrue(feature.isSupported(flavour: .pleroma, version: nil, apiVersions: pleromaApiVersions))

        // Test with version range requirement
        let featureWithRange = TootFeature(requirements: [
            .from(.mastodon, version: 3, to: 5)
        ])

        let akkomaApiVersionsInRange = InstanceV2.APIVersions(mastodon: 4)
        XCTAssertTrue(featureWithRange.isSupported(flavour: .akkoma, version: nil, apiVersions: akkomaApiVersionsInRange))

        let akkomaApiVersionsTooHigh = InstanceV2.APIVersions(mastodon: 6)
        XCTAssertFalse(featureWithRange.isSupported(flavour: .akkoma, version: nil, apiVersions: akkomaApiVersionsTooHigh))

        // Test that non-Mastodon requirements still require exact flavour match
        let pleromaFeature = TootFeature(requirements: [
            .from(.pleroma, displayVersion: "2.5.0")
        ])

        // Akkoma should NOT satisfy Pleroma-specific requirements
        XCTAssertFalse(pleromaFeature.isSupported(flavour: .akkoma, version: Version(tolerant: "2.5.0")))

        // Only Pleroma should satisfy Pleroma requirements
        XCTAssertTrue(pleromaFeature.isSupported(flavour: .pleroma, version: Version(tolerant: "2.5.0")))
    }
}
