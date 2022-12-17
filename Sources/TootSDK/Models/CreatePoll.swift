// Created by konstantin on 30/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// A request to create a new poll
public struct CreatePoll: Codable, Hashable {
    public init(expiresIn: Int, multiple: Bool? = nil, hideTotals: Bool? = nil, options: [String]) {
        self.expiresIn = expiresIn
        self.multiple = multiple
        self.hideTotals = hideTotals
        self.options = options
    }
    
    /// Integer. Duration that the poll should be open, in seconds. If provided, media_ids cannot be used, and poll[options] must be provided.
    public var expiresIn: Int
    ///  Does the poll allow multiple-choice answers? Defaults to false.
    public var multiple: Bool?
    ///  Hide vote counts until the poll ends? Defaults to false.
    public var hideTotals: Bool?
    /// Possible answers for the poll. If provided, media_ids cannot be used, and poll[expires_in] must be provided.
    public var options: [String]
    
    enum CodingKeys: String, CodingKey {
        case expiresIn = "expires_in"
        case multiple = "multiple"
        case hideTotals = "hide_totals"
        case options = "options"
    }
}
