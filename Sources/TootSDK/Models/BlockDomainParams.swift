// Created by konstantin on 10/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Parameters to block a domain
public struct BlockDomainParams: Codable {

    /// Domain to block.
    public var domain: String

    /// Whether to apply a silence, suspend, or noop to the domain. Defaults to silence
    public var severity: DomainBlockSeverity?

    /// Whether media attachments should be rejected. Defaults to false
    public var rejectMedia: Bool?

    /// Whether reports from this domain should be rejected. Defaults to false
    public var rejectReports: Bool?

    /// A private note about this domain block, visible only to admins.
    public var privateComment: String?

    /// A public note about this domain block, optionally shown on the about page.
    public var publicComment: String?

    /// Whether to partially censor the domain when shown in public. Defaults to false
    public var obfuscate: Bool?

    /// - Parameters:
    ///   - domain: Domain to block.
    ///   - severity: Whether to apply a silence, suspend, or noop to the domain. Defaults to silence
    ///   - rejectMedia: Whether media attachments should be rejected. Defaults to false
    ///   - rejectReports: Whether reports from this domain should be rejected. Defaults to false
    ///   - privateComment: A private note about this domain block, visible only to admins.
    ///   - publicComment: public note about this domain block, optionally shown on the about page.
    ///   - obfuscate: Whether to partially censor the domain when shown in public. Defaults to false
    public init(domain: String, severity: DomainBlockSeverity? = nil, rejectMedia: Bool? = nil, rejectReports: Bool? = nil, privateComment: String? = nil, publicComment: String? = nil, obfuscate: Bool? = nil) {
        self.domain = domain
        self.severity = severity
        self.rejectMedia = rejectMedia
        self.rejectReports = rejectReports
        self.privateComment = privateComment
        self.publicComment = publicComment
        self.obfuscate = obfuscate
    }
}
