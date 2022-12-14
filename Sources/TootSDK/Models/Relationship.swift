// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents the relationship between accounts,
/// such as following / blocking / muting / etc.
public struct Relationship: Codable, Hashable {
    public init(id: String,
                following: Bool,
                requested: Bool,
                endorsed: Bool? = nil,
                followedBy: Bool,
                muting: Bool,
                mutingNotifications: Bool? = nil,
                showingReblogs: Bool? = nil,
                notifying: Bool? = nil,
                blocking: Bool,
                domainBlocking: Bool,
                blockedBy: Bool? = nil,
                note: String? = nil) {
        self.id = id
        self.following = following
        self.requested = requested
        self.endorsed = endorsed
        self.followedBy = followedBy
        self.muting = muting
        self.mutingNotifications = mutingNotifications
        self.showingReblogs = showingReblogs
        self.notifying = notifying
        self.blocking = blocking
        self.domainBlocking = domainBlocking
        self.blockedBy = blockedBy
        self.note = note
    }

    /// The account id.
    public let id: String
    /// Are you following this user?
    public let following: Bool
    /// Do you have a pending follow request for this user?
    public let requested: Bool
    /// Are you featuring this user on your profile?
    public var endorsed: Bool?
    /// Are you followed by this user?
    public let followedBy: Bool
    /// Are you muting this user?
    public let muting: Bool
    /// Are you muting notifications from this user?
    public var mutingNotifications: Bool?
    /// Are you receiving this user's boosts in your home timeline?
    public var showingReblogs: Bool?
    /// Have you enabled notifications for this user?
    public let notifying: Bool?
    /// Are you blocking this user?
    public let blocking: Bool
    /// Are you blocking this user's domain?
    public let domainBlocking: Bool
    /// Is this user blocking you?
    public var blockedBy: Bool?
    /// This user's profile bio
    public var note: String?
}
