// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents the tree around a given post. Used for reconstructing threads of posts.
public struct Context: Codable, Hashable, Sendable {
    /// Parents in the thread.
    public var ancestors: [Post]

    /// Children in the thread.
    public var descendants: [Post]

    public init(ancestors: [Post], descendants: [Post]) {
        self.ancestors = ancestors
        self.descendants = descendants
    }
}
