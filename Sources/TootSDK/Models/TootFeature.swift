import Foundation

/// Represents a feature that is not supported by all flavours.
public struct TootFeature: Sendable {

    /// Flavours that support this feature.
    public let supportedFlavours: Set<TootSDKFlavour>
}
