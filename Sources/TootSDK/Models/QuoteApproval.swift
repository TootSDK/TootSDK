//
//  QuoteApproval.swift
//  TootSDK
//
//  Created by nixzhu on 11/18/25.
//

/// Summary of a status' quote approval policy and how it applies to the requesting user.
public struct QuoteApproval: Codable, Hashable, Sendable {
    public let automatic: [Policy]
    public let manual: [Policy]
    public let currentUser: CurrentUserPolicy?

    enum CodingKeys: String, CodingKey {
        case automatic
        case manual
        case currentUser = "current_user"
    }
}

extension QuoteApproval {
    public enum Policy: String, CaseIterable, Codable, Sendable {
        case `public`
        case followers
        case following
        case unsupported

        enum CodingKeys: String, CodingKey {
            case `public`
            case followers
            case following
            case unsupported = "unsupported_policy"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = .init(rawValue: rawValue) ?? .unsupported
        }
    }

    public enum CurrentUserPolicy: String, CaseIterable, Codable, Sendable {
        case automatic
        case manual
        case denied
        case unknown

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = .init(rawValue: rawValue) ?? .unknown
        }
    }
}
