//
//  InstanceRule.swift
//
//
//  Created by Dale Price on 10/26/23.
//

import Foundation

/// Represents a rule that server users should follow.
public struct InstanceRule: Codable, Hashable, Identifiable {
    /// Identifier for the rule.
    ///
    /// > Note: Cast from integer, but not guaranteed to be a number.
    public var id: String
    /// The text content of the rule.
    public var text: String?
    /// Optional text providing more details about the rule.
    public var hint: String?
}
