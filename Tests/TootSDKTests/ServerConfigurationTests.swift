import Version
import XCTest

@testable import TootSDK

final class ServerConfigurationTests: XCTestCase {

    func testServerConfigurationInitialization() throws {
        // Test default initialization
        let defaultConfig = ServerConfiguration()
        XCTAssertEqual(defaultConfig.flavour, .mastodon)
        XCTAssertNil(defaultConfig.version)
        XCTAssertNil(defaultConfig.versionString)
        XCTAssertNil(defaultConfig.apiVersions)

        // Test custom initialization
        let customConfig = ServerConfiguration(
            flavour: .pleroma,
            version: Version(4, 0, 0),
            versionString: "4.0.0",
            apiVersions: InstanceV2.APIVersions(mastodon: 1)
        )
        XCTAssertEqual(customConfig.flavour, .pleroma)
        XCTAssertEqual(customConfig.version, Version(4, 0, 0))
        XCTAssertEqual(customConfig.versionString, "4.0.0")
        XCTAssertEqual(customConfig.apiVersions?.mastodon, 1)
    }

    func testTootClientInitializationWithServerConfiguration() async throws {
        let serverConfig = ServerConfiguration(
            flavour: .akkoma,
            version: Version(3, 10, 3),
            versionString: "3.10.3 (Akkoma)",
            apiVersions: nil
        )

        let client = TootClient(
            instanceURL: URL(string: "https://example.com")!,
            serverConfiguration: serverConfig
        )

        // Verify the server configuration is properly set
        let flavour = await client.flavour
        let version = await client.version
        let versionString = await client.versionString
        let apiVersions = await client.apiVersions
        XCTAssertEqual(flavour, .akkoma)
        XCTAssertEqual(version, Version(3, 10, 3))
        XCTAssertEqual(versionString, "3.10.3 (Akkoma)")
        XCTAssertNil(apiVersions)

        let encoder = await client.makeEncoder()
        XCTAssertEqual(encoder.userInfo[.tootSDKFlavour] as? TootSDKFlavour, .akkoma)
    }

    func testServerConfigurationCodable() throws {
        let originalConfig = ServerConfiguration(
            flavour: .mastodon,
            version: Version(4, 2, 0),
            versionString: "4.2.0",
            apiVersions: InstanceV2.APIVersions(mastodon: 1)
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalConfig)

        // Decode
        let decoder = JSONDecoder()
        let decodedConfig = try decoder.decode(ServerConfiguration.self, from: data)

        // Verify
        XCTAssertEqual(decodedConfig.flavour, originalConfig.flavour)
        XCTAssertEqual(decodedConfig.version?.description, originalConfig.version?.description)
        XCTAssertEqual(decodedConfig.versionString, originalConfig.versionString)
        XCTAssertEqual(decodedConfig.apiVersions, originalConfig.apiVersions)
    }

    func testServerConfigurationEquality() throws {
        let config1 = ServerConfiguration(
            flavour: .mastodon,
            version: Version(4, 0, 0),
            versionString: "4.0.0",
            apiVersions: InstanceV2.APIVersions(mastodon: 1)
        )

        let config2 = ServerConfiguration(
            flavour: .mastodon,
            version: Version(4, 0, 0),
            versionString: "4.0.0",
            apiVersions: InstanceV2.APIVersions(mastodon: 1)
        )

        let config3 = ServerConfiguration(
            flavour: .pleroma,
            version: Version(4, 0, 0),
            versionString: "4.0.0",
            apiVersions: InstanceV2.APIVersions(mastodon: 1)
        )

        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }

    func testBackwardCompatibility() async throws {
        // Test that existing code still works with the default TootClient initializer
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)

        // The default configuration should be Mastodon
        let flavour = await client.flavour
        let version = await client.version
        let versionString = await client.versionString
        let apiVersions = await client.apiVersions
        XCTAssertEqual(flavour, .mastodon)
        XCTAssertNil(version)
        XCTAssertNil(versionString)
        XCTAssertNil(apiVersions)
    }
}
