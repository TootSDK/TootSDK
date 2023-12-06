//
//  FilterResult.swift
//
//
//  Created by Philip Chu on 12/2/23.
//

import Foundation

public struct FilterResult: Codable, Hashable {

    public init(filter: Filter, keywordMatches: [String]? = nil, postMatches: [String]? = nil) {
        self.filter = filter
        self.keywordMatches = keywordMatches
        self.postMatches = postMatches
    }

    /// The filter that was matched.
    public var filter: Filter
    /// The keyword within the filter that was matched.
    public var keywordMatches: [String]?
    /// The post ID within the filter that was matched.
    public var postMatches: [String]?

    enum CodingKeys: String, CodingKey {
        case filter
        case keywordMatches
        case postMatches = "statusMatches"
    }
}
