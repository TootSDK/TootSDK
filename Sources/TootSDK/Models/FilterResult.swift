//
//  FilterResult.swift
//
//
//  Created by Philip Chu on 12/2/23.
//

import Foundation

public struct FilterResult: Codable, Hashable {
    /// The filter that was matched.
    public var filter: Filter
    /// The keyword within the filter that was matched.
    public var keywordMatches: [String]?
    /// The status ID within the filter that was matched.
    public var statusMatches: [String]?
}
