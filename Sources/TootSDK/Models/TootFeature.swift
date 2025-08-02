import Foundation
import Version

/// Represents a feature that is not supported by all flavours.
public struct TootFeature: Equatable {

    /// Represents a flavour requirement with optional version constraints
    public struct FlavourRequirement: Equatable {
        let flavour: TootSDKFlavour
        let minVersion: Version?
        let maxVersion: Version?

        /// Create a requirement for any version of a flavour
        public static func any(_ flavour: TootSDKFlavour) -> FlavourRequirement {
            FlavourRequirement(flavour: flavour, minVersion: nil, maxVersion: nil)
        }

        /// Create a requirement for a minimum version
        public static func from(_ flavour: TootSDKFlavour, version: String) -> FlavourRequirement {
            FlavourRequirement(flavour: flavour, minVersion: Version(tolerant: version), maxVersion: nil)
        }

        /// Create a requirement for a version range
        public static func range(_ flavour: TootSDKFlavour, from: String, to: String) -> FlavourRequirement {
            FlavourRequirement(
                flavour: flavour,
                minVersion: Version(tolerant: from),
                maxVersion: Version(tolerant: to)
            )
        }

        /// Create a requirement for a maximum version
        public static func until(_ flavour: TootSDKFlavour, version: String) -> FlavourRequirement {
            FlavourRequirement(flavour: flavour, minVersion: nil, maxVersion: Version(tolerant: version))
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

    /// Initialize with "any flavour except specific version requirements" pattern
    /// - Parameters:
    ///   - anyExcept: Flavours that should support any version
    ///   - versionRequirements: Specific version requirements for certain flavours
    public init(anyExcept: Set<TootSDKFlavour>, versionRequirements: [FlavourRequirement]) {
        // Create requirements for "any version" flavours
        let anyRequirements = anyExcept.map { FlavourRequirement.any($0) }
        // Combine with specific version requirements
        self.requirements = anyRequirements + versionRequirements
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

    /// Check if feature is supported by an instance (for testing)
    public func isSupported(by instance: any Instance) -> Bool {
        return isSupported(flavour: instance.flavour, version: instance.version)
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
                if let minVersion = req.minVersion, version < minVersion {
                    return false
                }
                if let maxVersion = req.maxVersion, version > maxVersion {
                    return false
                }
            } else if req.minVersion != nil || req.maxVersion != nil {
                // Version required but not available
                return false
            }

            return true
        }
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
