// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Context: Codable, Hashable {
    public var ancestors: [Status]
    public var descendants: [Status]

    public init(ancestors: [Status], descendants: [Status]) {
        self.ancestors = ancestors
        self.descendants = descendants
    }
}
