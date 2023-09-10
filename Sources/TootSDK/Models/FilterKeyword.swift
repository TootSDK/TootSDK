// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct FilterKeyword: Codable, Hashable, Identifiable {

    /// The ID of the FilterKeyword in the database.
    public var id: String
    /// The phrase to be matched against.
    public var keyword: String
    /// Should the filter consider word boundaries?
    public var wholeWord: Bool
}
