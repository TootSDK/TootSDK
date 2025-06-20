//
//  OpenEnum.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 17/06/2025.
//

import Foundation

/// A generic enum that wraps a known `RawRepresentable` value or an unknown value encountered during decoding.
///
/// This is used to model server-provided values that may include new or custom cases not yet known to TootSDK.
///
/// Use `OpenEnum` as a property wrapper for enums with a raw value, allowing you to safely decode and handle unknown values from the server.
///
/// - Note: This approach ensures forward compatibility with new enum values returned by the server.
///
/// Example:
/// ```swift
/// enum Visibility: String, Codable, CaseIterable, Sendable {
///     case `public`, unlisted, `private`, direct
/// }
///
/// struct Post: Codable {
///     var visibility: OpenEnum<Visibility>
/// }
///
/// let post = Post(visibility: .public)
/// // Setting a known value
/// post.visibility = .some(.private)
/// // Handling an unknown value from the server
/// let unknown = OpenEnum<Visibility>.unparsedByTootSDK(rawValue: "custom")
/// post.visibility = unknown
/// // Reading the value
/// switch post.visibility {
/// case .some(let vis):
///     print("Known visibility: \(vis)")
/// case .unparsedByTootSDK(let raw):
///     print("Unknown visibility: \(raw)")
/// }
/// ```
///
/// The `OpenEnum` type enables the handling of cases that are not explicitly defined in the enum,
/// by providing a raw value initializer and a way to access the unparsed value.
///
/// Conforming to `OpenEnum` requires implementing the `init?(rawValue:)` initializer and the
/// `var rawValue: String { get }` property. The `rawValue` should be of the same type as the enum's
/// raw value type, and the initializer should attempt to create an instance of the enum from the
/// given raw value, falling back to a case for unparsed values if necessary.
///
/// In the example, the `Visibility` enum conforms to `OpenEnum` with a `String` raw value type.
/// The case `unparsedByTootSDK` is used to represent any unknown visibility value received from the
/// server that is not explicitly handled by the enum cases.
@frozen public enum OpenEnum<Wrapped: RawRepresentable & Sendable>: Sendable where Wrapped.RawValue: Sendable {
    /// Represents a known, successfully parsed value.
    case some(Wrapped)

    /// Represents a raw value that couldn't be parsed into the known `Wrapped` type.
    case unparsedByTootSDK(rawValue: Wrapped.RawValue)

    /// Returns the underlying raw value, whether the case is a known or unparsed value.
    public var rawValue: Wrapped.RawValue {
        switch self {
        case .some(let wrapped):
            return wrapped.rawValue
        case .unparsedByTootSDK(let rawValue):
            return rawValue
        }
    }

    /// Returns the wrapped enum value if it is recognized, or `nil` if the raw value was not parsed into a known case.
    public var value: Wrapped? {
        switch self {
        case .some(let wrapped):
            return wrapped
        case .unparsedByTootSDK:
            return nil
        }
    }

    /// Wraps an optional `Wrapped` value into an optional `OpenEnum`.
    ///
    /// - Returns: `.some(value)` if the input is non-nil, or `nil` if the input is nil.
    public static func optional(_ value: Wrapped?) -> Self? {
        if let value {
            return .some(value)
        }
        return nil
    }
}

extension OpenEnum: Codable where Wrapped.RawValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Wrapped.RawValue.self)
        if let wrapped = Wrapped(rawValue: rawValue) {
            self = .some(wrapped)
        } else {
            self = .unparsedByTootSDK(rawValue: rawValue)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension OpenEnum: Equatable where Wrapped: Equatable, Wrapped.RawValue: Equatable {
}

extension OpenEnum: Hashable where Wrapped: Hashable, Wrapped.RawValue: Hashable {
}

@available(iOS 15.4, macOS 12.3, tvOS 15.4, watchOS 8.5, *)
extension OpenEnum: CodingKeyRepresentable where Wrapped: CodingKeyRepresentable, Wrapped.RawValue: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        switch self {
        case .some(let wrapped):
            return wrapped.codingKey
        case .unparsedByTootSDK(let rawValue):
            return rawValue.codingKey
        }
    }

    public init?(codingKey: some CodingKey) {
        if let wrapped = Wrapped(codingKey: codingKey) {
            self = .some(wrapped)
        } else if let rawValue = Wrapped.RawValue(codingKey: codingKey) {
            self = .unparsedByTootSDK(rawValue: rawValue)
        } else {
            return nil
        }
    }
}
