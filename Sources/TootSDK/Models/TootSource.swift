// Created by konstantin on 02/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents display or publishing preferences of user's own account. Returned as an additional entity when verifying and updated credentials, as an attribute of Account.
public struct TootSource: Codable, Hashable {
    public init(note: String? = nil, fields: [TootField], privacy: Post.Visibility? = nil, sensitive: Bool? = nil, language: String? = nil, followRequestsCount: Int? = nil) {
        self.note = note
        self.fields = fields
        self.privacy = privacy
        self.sensitive = sensitive
        self.language = language
        self.followRequestsCount = followRequestsCount
    }

    /// Profile bio.
    public var note: String?
    /// Metadata about the account.
    public var fields: [TootField]
    /// The default post privacy to be used for new posts.
    public var privacy: Post.Visibility?
    /// Whether new posts should be marked sensitive by default.
    public var sensitive: Bool?
    ///  The default posting language for new posts.
    public var language: String?
    /// The number of pending follow requests.
    public var followRequestsCount: Int?
}
