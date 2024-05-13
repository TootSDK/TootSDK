// Created by konstantin on 22/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Alerts: Codable, Hashable, Sendable {
    public init(
        follow: Bool,
        favourite: Bool,
        repost: Bool,
        mention: Bool,
        poll: Bool? = nil,
        followRequest: Bool? = nil,
        post: Bool? = nil,
        update: Bool? = nil,
        adminSignUp: Bool? = nil,
        adminReport: Bool? = nil
    ) {
        self.follow = follow
        self.favourite = favourite
        self.repost = repost
        self.mention = mention
        self.poll = poll
        self.followRequest = followRequest
        self.post = post
        self.update = update
        self.adminSignUp = adminSignUp
        self.adminReport = adminReport
    }

    /// Receive a push notification when someone has followed you.
    public var follow: Bool
    /// Receive a push notification when a post you created has been favourited by someone else.
    public var favourite: Bool
    /// Receive a push notification when a post you created has been boosted by someone else.
    public var repost: Bool
    /// Receive a push notification when someone else has mentioned you in a post.
    public var mention: Bool
    /// Receive a push notification when a poll you voted in or created has ended. Added in 2.8.0
    public var poll: Bool?
    /// Receive a push notification when someone requested to follow you.
    public var followRequest: Bool?
    /// Receive a push notification when someone you enabled notifications for has submitted a post.
    public var post: Bool?
    /// Receive a push notification when a post you boosted with has been edited.
    public var update: Bool?
    /// Receive a push notification when someone signs up.
    public var adminSignUp: Bool?
    /// Receive a push notification about a new report.
    public var adminReport: Bool?

    enum CodingKeys: String, CodingKey {
        case follow
        case favourite
        case repost = "reblog"
        case mention
        case poll
        case followRequest
        case post = "status"
        case update
        case adminSignUp = "admin.sign_up"
        case adminReport = "admin.report"
    }
}
