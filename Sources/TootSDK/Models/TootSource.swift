// Created by konstantin on 02/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents display or publishing preferences of user's own account. Returned as an additional entity when verifying and updated credentials, as an attribute of Account.
public struct TootSource: Codable, Hashable, Sendable {
    public init(
        note: String? = nil,
        fields: [TootField],
        privacy: Post.Visibility? = nil,
        sensitive: Bool? = nil,
        quotePolicy: QuotePolicy? = nil,
        language: String? = nil,
        followRequestsCount: Int? = nil,
        indexable: Bool? = nil,
        hideCollections: Bool? = nil,
        discoverable: Bool? = nil,
        attributionDomains: [String]? = nil
    ) {
        self.note = note
        self.fields = fields
        self.privacy = .optional(privacy)
        self.sensitive = sensitive
        self.quotePolicy = quotePolicy
        self.language = language
        self.followRequestsCount = followRequestsCount
        self.indexable = indexable
        self.hideCollections = hideCollections
        self.discoverable = discoverable
        self.attributionDomains = attributionDomains
    }

    /// Profile bio.
    public var note: String?
    /// Metadata about the account.
    public var fields: [TootField]
    /// The default post privacy to be used for new posts.
    public var privacy: OpenEnum<Post.Visibility>?
    /// Whether new posts should be marked sensitive by default.
    public var sensitive: Bool?
    /// The default policy to quote post.
    public var quotePolicy: QuotePolicy?
    ///  The default posting language for new posts.
    public var language: String?
    /// The number of pending follow requests.
    public var followRequestsCount: Int?
    /// Whether public posts should be searchable to anyone.
    public let indexable: Bool?
    /// Whether to hide followers and followed accounts.
    public let hideCollections: Bool?
    /// Whether the account has opted into discovery features such as the profile directory
    public let discoverable: Bool?
    /// Domains of websites allowed to credit the account in link preview cards.
    public let attributionDomains: [String]?
}
