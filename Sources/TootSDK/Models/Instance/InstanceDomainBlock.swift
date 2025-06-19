//
//  InstanceDomainBlock.swift
//  TootSDK
//
//  Created by Dale Price on 5/12/25.
//

import Foundation

/// Represents a domain that is blocked by the instance.
public struct InstanceDomainBlock: Codable, Hashable, Sendable {
    /// The domain that is blocked. This may be obfuscated or partially censored.
    public var domain: String
    /// The SHA256 hash digest of the domain string.
    public var digest: String?
    /// The level to which the domain is blocked.
    public var severity: OpenEnum<DomainBlockSeverity>
    /// An optional reason for the domain block.
    public var comment: String?

    public init(domain: String, digest: String? = nil, severity: DomainBlockSeverity, comment: String? = nil) {
        self.domain = domain
        self.digest = digest
        self.severity = .some(severity)
        self.comment = comment
    }
}
