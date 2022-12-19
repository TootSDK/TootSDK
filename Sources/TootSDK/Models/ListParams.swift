// Created by konstantin on 19/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Params to change a list of users
public struct ListParams: Codable {
    /// The user-defined title of the list.
    public var title: String
    /// The user-defined title of the list.
    public var repliesPolicy: ListRepliesPolicy?
    
    public init(title: String, repliesPolicy: ListRepliesPolicy? = nil) {
        self.title = title
        self.repliesPolicy = repliesPolicy
    }
}
