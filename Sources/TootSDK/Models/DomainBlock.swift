//
//  File.swift
//  
//
//  Created by dave on 14/12/22.
//

import Foundation

/// The policy to be applied by this domain block.
///   - silence = Account posts from this domain will be hidden by default
///   - suspend = All incoming data from this domain will be rejected
///   - noop = Do nothing. Allows for rejecting media or reports
public enum DomainBlockSeverity: String, Codable, Hashable {
    case silence ///
    case suspend
    case noop
}

/// Represents a domain limited from federating.
public struct DomainBlock: Codable, Hashable {
    /// The ID of the DomainBlock in the database.
    public var id: String?
    
    /// The domain that is not allowed to federate.
    public var domain: String
    
    /// When the domain was blocked from federating.
    public var createdAt: Date?
    
    /// The policy to be applied by this domain block.
    public var severity: DomainBlockSeverity?
    
    /// Whether to reject media attachments from this domain
    public var rejectMedia: Bool?
    
    /// Whether to reject reports from this domain
    public var rejectReports: Bool?
    
    /// A private note about this domain block, visible only to admins.
    public var privateComment: String?
    
    /// public note about this domain block, optionally shown on the about page.
    public var publicComment: String?
    
    /// Whether to partially censor the domain when shown in public. Defaults to false
    public var obfuscate: Bool = false
    
    /// - Parameters:
    ///   - id: The ID of the DomainBlock in the database.
    ///   - domain: The domain that is not allowed to federate.
    ///   - createdAt: When the domain was blocked from federating.
    ///   - severity: The policy to be applied by this domain block.
    ///   - rejectMedia: The policy to be applied by this domain block.
    ///   - rejectReports: Whether to reject reports from this domain
    ///   - privateComment: A private note about this domain block, visible only to admins.
    ///   - publicComment: public note about this domain block, optionally shown on the about page.
    ///   - obfuscate: Whether to partially censor the domain when shown in public. Defaults to false
    public init(id: String?,
                domain: String,
                createdAt: Date?,
                severity: DomainBlockSeverity?,
                rejectMedia: Bool?,
                rejectReports: Bool?,
                privateComment: String? = nil,
                publicComment: String? = nil,
                obfuscate: Bool = false) {
        self.id = id
        self.domain = domain
        self.createdAt = createdAt
        self.severity = severity
        self.rejectMedia = rejectMedia
        self.rejectReports = rejectReports
        self.privateComment = privateComment
        self.publicComment = publicComment
        self.obfuscate = obfuscate
    }
}
