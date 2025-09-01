// ABOUTME: Encapsulates server state information for TootClient including flavour, version, and API details.
// ABOUTME: This struct makes it easier to cache and restore TootClient instances with pre-configured server state.

import Foundation
import Version

/// Encapsulates the server configuration state for a TootClient instance.
/// This includes information about the server's flavour, version, and supported API versions.
public struct ServerConfiguration: Sendable, Codable, Hashable {
    /// The detected fediverse server flavour (e.g., Mastodon, Pleroma, etc.)
    public let flavour: TootSDKFlavour
    
    /// The parsed semantic version of the server (used for feature detection)
    public let version: Version?
    
    /// The raw version string from the server (for debugging/display purposes)
    public let versionString: String?
    
    /// The API versions supported by the server (from InstanceV2 response)
    public let apiVersions: InstanceV2.APIVersions?
    
    /// Creates a new ServerConfiguration instance.
    /// - Parameters:
    ///   - flavour: The server flavour
    ///   - version: The parsed semantic version
    ///   - versionString: The raw version string
    ///   - apiVersions: The supported API versions
    public init(
        flavour: TootSDKFlavour = .mastodon,
        version: Version? = nil,
        versionString: String? = nil,
        apiVersions: InstanceV2.APIVersions? = nil
    ) {
        self.flavour = flavour
        self.version = version
        self.versionString = versionString
        self.apiVersions = apiVersions
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case flavour
        case version
        case versionString
        case apiVersions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.flavour = try container.decode(TootSDKFlavour.self, forKey: .flavour)
        
        // Decode Version as a string and parse it
        if let versionString = try container.decodeIfPresent(String.self, forKey: .version) {
            self.version = Version(versionString)
        } else {
            self.version = nil
        }
        
        self.versionString = try container.decodeIfPresent(String.self, forKey: .versionString)
        self.apiVersions = try container.decodeIfPresent(InstanceV2.APIVersions.self, forKey: .apiVersions)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(flavour, forKey: .flavour)
        
        // Encode Version as a string
        if let version = version {
            try container.encode(version.description, forKey: .version)
        }
        
        try container.encodeIfPresent(versionString, forKey: .versionString)
        try container.encodeIfPresent(apiVersions, forKey: .apiVersions)
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(flavour)
        if let version = version {
            hasher.combine(version.description)
        }
        hasher.combine(versionString)
        hasher.combine(apiVersions)
    }
    
    public static func == (lhs: ServerConfiguration, rhs: ServerConfiguration) -> Bool {
        return lhs.flavour == rhs.flavour &&
               lhs.version?.description == rhs.version?.description &&
               lhs.versionString == rhs.versionString &&
               lhs.apiVersions == rhs.apiVersions
    }
}