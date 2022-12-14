// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct IdentityProof: Codable, Hashable {
    public init(provider: String, providerUsername: String, profileUrl: String, proofUrl: String, updatedAt: Date) {
        self.provider = provider
        self.providerUsername = providerUsername
        self.profileUrl = profileUrl
        self.proofUrl = proofUrl
        self.updatedAt = updatedAt
    }

    /// The name of the identity provider.
    public var provider: String
    /// The account owner's username on the identity provider's service.
    public var providerUsername: String
    /// The account owner's profile URL on the identity provider.
    public var profileUrl: String
    /// A link to a statement of identity proof, hosted by the identity provider.
    public var proofUrl: String
    /// When the identity proof was last updated.
    public var updatedAt: Date
}
