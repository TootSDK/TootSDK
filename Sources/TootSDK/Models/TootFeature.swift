import Foundation
import Version

/// Represents a feature that is not supported by all flavours.
public struct TootFeature: Equatable {

    /// Represents a flavour requirement with optional version constraints
    public struct FlavourRequirement: Equatable {
        let flavour: TootSDKFlavour
        let minDisplayVersion: Version?
        let maxDisplayVersion: Version?
        let minVersion: Int?  // API version minimum
        let maxVersion: Int?  // API version maximum

        /// Create a requirement for any version of a flavour
        public static func any(_ flavour: TootSDKFlavour) -> FlavourRequirement {
            FlavourRequirement(flavour: flavour, minDisplayVersion: nil, maxDisplayVersion: nil, minVersion: nil, maxVersion: nil)
        }

        // MARK: - API Version Requirements (Primary/Default)

        /// Create a requirement for a minimum API version
        /// - Parameters:
        ///   - flavour: The server flavour
        ///   - version: The minimum API version required
        public static func from(_ flavour: TootSDKFlavour, version: Int) -> FlavourRequirement {
            FlavourRequirement(flavour: flavour, minDisplayVersion: nil, maxDisplayVersion: nil, minVersion: version, maxVersion: nil)
        }

        /// Create a requirement for an API version range
        /// - Parameters:
        ///   - flavour: The server flavour
        ///   - version: The minimum API version required
        ///   - to: The maximum API version supported
        public static func from(_ flavour: TootSDKFlavour, version: Int, to maxVersion: Int) -> FlavourRequirement {
            FlavourRequirement(flavour: flavour, minDisplayVersion: nil, maxDisplayVersion: nil, minVersion: version, maxVersion: maxVersion)
        }

        /// Create a requirement for a maximum API version
        /// - Parameters:
        ///   - flavour: The server flavour
        ///   - version: The maximum API version supported
        public static func until(_ flavour: TootSDKFlavour, version: Int) -> FlavourRequirement {
            FlavourRequirement(flavour: flavour, minDisplayVersion: nil, maxDisplayVersion: nil, minVersion: nil, maxVersion: version)
        }

        // MARK: - Display Version Requirements (Fallback/Legacy)

        /// Create a requirement for a minimum display version
        /// - Parameters:
        ///   - flavour: The server flavour
        ///   - displayVersion: The minimum display version required
        public static func from(_ flavour: TootSDKFlavour, displayVersion: String) -> FlavourRequirement {
            FlavourRequirement(
                flavour: flavour, minDisplayVersion: Version(tolerant: displayVersion), maxDisplayVersion: nil, minVersion: nil, maxVersion: nil)
        }

        /// Create a requirement for a display version range
        /// - Parameters:
        ///   - flavour: The server flavour
        ///   - displayVersion: The minimum display version required
        ///   - to: The maximum display version supported
        public static func from(_ flavour: TootSDKFlavour, displayVersion: String, to maxDisplayVersion: String) -> FlavourRequirement {
            FlavourRequirement(
                flavour: flavour,
                minDisplayVersion: Version(tolerant: displayVersion),
                maxDisplayVersion: Version(tolerant: maxDisplayVersion),
                minVersion: nil,
                maxVersion: nil
            )
        }

        /// Create a requirement for a maximum display version
        /// - Parameters:
        ///   - flavour: The server flavour
        ///   - displayVersion: The maximum display version supported
        public static func until(_ flavour: TootSDKFlavour, displayVersion: String) -> FlavourRequirement {
            FlavourRequirement(
                flavour: flavour, minDisplayVersion: nil, maxDisplayVersion: Version(tolerant: displayVersion), minVersion: nil, maxVersion: nil)
        }

        // MARK: - Combined Requirements

        /// Create a requirement with both API version and display version fallback
        /// - Parameters:
        ///   - flavour: The server flavour
        ///   - version: The minimum API version required
        ///   - fallbackDisplayVersion: The minimum display version to use as fallback when API version is not available (optional)
        public static func from(_ flavour: TootSDKFlavour, version: Int, fallbackDisplayVersion: String? = nil) -> FlavourRequirement {
            FlavourRequirement(
                flavour: flavour,
                minDisplayVersion: fallbackDisplayVersion.flatMap { Version(tolerant: $0) },
                maxDisplayVersion: nil,
                minVersion: version,
                maxVersion: nil
            )
        }

    }

    /// The requirements for this feature
    public let requirements: [FlavourRequirement]

    /// Legacy initializer for backward compatibility
    public init(supportedFlavours: Set<TootSDKFlavour>) {
        self.requirements = supportedFlavours.map { FlavourRequirement.any($0) }
    }

    /// New version-aware initializer
    public init(requirements: [FlavourRequirement]) {
        self.requirements = requirements
    }

    /// Initialize with flavours that support any version plus specific version requirements for other flavours
    /// - Parameters:
    ///   - anyVersion: Flavours that support any version
    ///   - requirements: Specific version requirements for certain flavours
    public init(anyVersion: Set<TootSDKFlavour>, requirements: [FlavourRequirement]) {
        // Create requirements for "any version" flavours
        let anyRequirements = anyVersion.map { FlavourRequirement.any($0) }
        // Combine with specific version requirements
        self.requirements = anyRequirements + requirements
    }

    /// Initialize with default support for all flavours except specific version requirements
    /// Useful for features that are generally available but have version constraints on certain servers
    /// - Parameter versionRequirements: Specific version requirements for certain flavours
    public init(allExcept versionRequirements: [FlavourRequirement]) {
        // Get all flavours not mentioned in version requirements
        let flavoursWithRequirements = Set(versionRequirements.map { $0.flavour })
        let anyFlavours = Set(TootSDKFlavour.allCases).subtracting(flavoursWithRequirements)

        // Create requirements for "any version" flavours
        let anyRequirements = anyFlavours.map { FlavourRequirement.any($0) }
        // Combine with specific version requirements
        self.requirements = anyRequirements + versionRequirements
    }

    /// Check if feature is supported by an instance
    public func isSupported(by instance: any Instance) -> Bool {
        // Parse version string
        let versionObj = Self.parseVersion(from: instance.version)

        // For InstanceV2, use the API versions if available
        if let instanceV2 = instance as? InstanceV2 {
            return isSupported(flavour: instanceV2.flavour, version: versionObj, apiVersions: instanceV2.apiVersions)
        }

        // For InstanceV1 or other instances, no API versions available
        return isSupported(flavour: instance.flavour, version: versionObj, apiVersions: nil)
    }

    /// Check if feature is supported by a specific flavour and version string
    public func isSupported(flavour: TootSDKFlavour, version: String?) -> Bool {
        // Parse version with fallback to regex extraction
        let versionObj = version.flatMap { Self.parseVersion(from: $0) }
        return isSupported(flavour: flavour, version: versionObj)
    }

    /// Check if feature is supported by a specific flavour and parsed version
    public func isSupported(flavour: TootSDKFlavour, version: Version?) -> Bool {
        return requirements.contains { req in
            guard req.flavour == flavour else { return false }

            if let version = version {
                if let minVersion = req.minDisplayVersion, version < minVersion {
                    return false
                }
                if let maxVersion = req.maxDisplayVersion, version > maxVersion {
                    return false
                }
            } else if req.minDisplayVersion != nil || req.maxDisplayVersion != nil {
                // Version required but not available
                return false
            }

            return true
        }
    }

    /// Check if feature is supported considering API versions when available
    /// - Parameters:
    ///   - flavour: The server flavour
    ///   - version: The parsed display version
    ///   - apiVersions: The API versions from InstanceV2 (if available)
    /// - Returns: true if the feature is supported
    public func isSupported(flavour: TootSDKFlavour, version: Version?, apiVersions: InstanceV2.APIVersions?) -> Bool {
        return requirements.contains { req in
            guard req.flavour == flavour else { return false }

            // Check API version requirements if present
            if req.minVersion != nil || req.maxVersion != nil {
                // Check against the Mastodon API version regardless of server flavour
                // Any server that provides a mastodon API version should be checked against it
                if req.flavour == .mastodon, let mastodonApiVersion = apiVersions?.mastodon {
                    if let minVersion = req.minVersion, mastodonApiVersion < minVersion {
                        return false
                    }
                    if let maxVersion = req.maxVersion, mastodonApiVersion > maxVersion {
                        return false
                    }
                    // API version requirements met
                    return true
                } else if apiVersions == nil {
                    // No API version available
                    // Fall back to display version if one is specified
                    if req.minDisplayVersion != nil || req.maxDisplayVersion != nil {
                        return checkDisplayVersion(req: req, version: version)
                    } else if Self.supportsInstanceV2(flavour) {
                        // This flavour supports instanceV2 but didn't provide API versions
                        // The feature is not supported (no fallback)
                        return false
                    } else {
                        // This flavour doesn't support instanceV2, cannot check API version
                        return false
                    }
                } else {
                    // API versions available but not for this flavour
                    // Fall back to display version if specified
                    if req.minDisplayVersion != nil || req.maxDisplayVersion != nil {
                        return checkDisplayVersion(req: req, version: version)
                    }
                    return false
                }
            }

            // Check display version requirements if no API version requirement
            if req.minVersion == nil && req.maxVersion == nil {
                return checkDisplayVersion(req: req, version: version)
            }

            // Should not reach here
            return false
        }
    }

    /// Check if a flavour supports instanceV2 API
    private static func supportsInstanceV2(_ flavour: TootSDKFlavour) -> Bool {
        return TootFeature.instanceV2.supportedFlavours.contains(flavour)
    }

    private func checkDisplayVersion(req: FlavourRequirement, version: Version?) -> Bool {
        if let version = version {
            if let minVersion = req.minDisplayVersion, version < minVersion {
                return false
            }
            if let maxVersion = req.maxDisplayVersion, version > maxVersion {
                return false
            }
        } else if req.minDisplayVersion != nil || req.maxDisplayVersion != nil {
            // Version required but not available
            return false
        }
        return true
    }

    /// Parse version from string with fallback to regex extraction
    public static func parseVersion(from versionString: String) -> Version? {
        // First try the Version library's tolerant parsing
        if let version = Version(tolerant: versionString) {
            return version
        }

        // If that fails, use regex to find the first version-like pattern
        let pattern = #"\d+\.\d+(?:\.\d+)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let range = NSRange(location: 0, length: versionString.utf16.count)
        guard let match = regex.firstMatch(in: versionString, options: [], range: range) else {
            return nil
        }

        guard let matchRange = Range(match.range, in: versionString) else {
            return nil
        }

        let extractedVersion = String(versionString[matchRange])
        return Version(tolerant: extractedVersion)
    }

    /// Legacy computed property for backward compatibility
    public var supportedFlavours: Set<TootSDKFlavour> {
        Set(requirements.map { $0.flavour })
    }
}
