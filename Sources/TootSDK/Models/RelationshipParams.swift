//
//  RelationshipParams.swift
//
//
//  Created by Philip Chu on 4/5/24.
//

import Foundation

public struct RelationshipParams: Codable, Sendable {

    /// Whether relationships should be returned for suspended users, defaults to false.
    public var withSuspended: Bool?

    public init(withSuspended: Bool? = nil) {
        self.withSuspended = withSuspended
    }
}

extension RelationshipParams {
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(
                name: "with_suspended",
                value: withSuspended?.description)
        ].filter { $0.value != nil }
    }
}
