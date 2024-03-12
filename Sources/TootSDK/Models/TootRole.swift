import Foundation

/// The role assigned to the currently authorized user.
/// Added to Mastodon API version 4.0.0
/// https://docs.joinmastodon.org/entities/Role/
public struct TootRole: Codable, Hashable, Sendable {
    public init(
        id: Int, name: String, color: String, permissions: Int, highlighted: Bool
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.permissions = permissions
        self.highlighted = highlighted
    }
    
    /// The ID of the Role in the database.
    public var id: Int
    /// The name of the role.
    public var name: String
    /// The hex code assigned to this role. If no hex code is assigned, the string will be empty.
    public var color: String
    /// A bitmask that represents the sum of all permissions granted to the role.
    public var permissions: Int
    /// Whether the role is publicly visible as a badge on user profiles.
    public var highlighted: Bool
}
    
    
