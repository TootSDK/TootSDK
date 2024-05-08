//
//  RelationshipSeveranceEvent.swift
//
//
//  Created by Łukasz Rutkowski on 08/05/2024.
//

import Foundation

public struct RelationshipSeveranceEvent: Codable, Sendable, Hashable, Identifiable {
    public let id: String
    public let type: EventType
    public let purged: Bool
    public let targetName: String
    public let relationshipsCount: Int?
    public let createdAt: Date

    public enum EventType: String, Codable, Sendable {
        case domainBlock = "domain_block"
        case userDomainBlock = "user_domain_block"
        case accountSuspension = "account_suspension"
    }
}
