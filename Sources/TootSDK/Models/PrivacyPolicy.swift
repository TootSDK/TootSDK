import Foundation

/// The privacy policy of an instance.
public struct PrivacyPolicy: Codable, Hashable, Sendable {

    /// A timestamp of when the policy was last updated.
    /// Note: this is not optional in the Mastodon spec but in practice sometimes null
    public var updatedAt: Date?

    /// The rendered HTML content of the privacy policy.
    public var content: String

    public init(updatedAt: Date? = nil, content: String = "") {
        self.updatedAt = updatedAt
        self.content = content
    }
}
