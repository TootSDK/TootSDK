// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents a list of some users that the authenticated user follows.
public struct List: Codable, Hashable, Identifiable {
    /// The internal database ID of the list.
    public var id: String
    /// The user-defined title of the list.
    public var title: String
    /// The user-defined title of the list.
    public var repliesPolicy: RepliesPolicy

    public enum RepliesPolicy: String, Hashable, Codable {
        ///  Show replies to any followed user
        case followed
        /// Show replies to members of the list
        case list
        /// Show replies to no one
        case none
    }
}
