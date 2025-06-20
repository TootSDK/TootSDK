//
//  OpenEnum.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 17/06/2025.
//

import Foundation

/// A generic enum that wraps a known `RawRepresentable` value or an unknown value encountered during decoding.
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
