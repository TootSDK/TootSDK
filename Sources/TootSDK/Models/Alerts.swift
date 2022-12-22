// Created by konstantin on 22/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Alerts: Codable, Hashable {
    public init(follow: Bool, favourite: Bool, repost: Bool, mention: Bool, poll: Bool? = nil, followRequest: Bool? = nil, status: Bool? = nil) {
        self.follow = follow
        self.favourite = favourite
        self.repost = repost
        self.mention = mention
        self.poll = poll
        self.followRequest = followRequest
        self.status = status
    }
    
    /// Receive a push notification when someone has followed you? Boolean.
    public var follow: Bool
    /// Receive a push notification when a status you created has been favourited by someone else? Boolean.
    public var favourite: Bool
    /// Receive a push notification when a status you created has been boosted by someone else? Boolean.
    public var repost: Bool
    /// Receive a push notification when someone else has mentioned you in a status? Boolean.
    public var mention: Bool
    /// Receive a push notification when a poll you voted in or created has ended? Boolean. Added in 2.8.0
    public var poll: Bool?
    public var followRequest: Bool?
    public var status: Bool?
    
    enum CodingKeys: String, CodingKey {
        case follow
        case favourite
        case repost = "reblog"
        case mention
        case poll
        case followRequest
        case status
    }
}
