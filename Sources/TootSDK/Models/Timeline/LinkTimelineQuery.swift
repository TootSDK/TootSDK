//
//  LinkTimelineQuery.swift
//  TootSDK
//
//  Created by Dale Price on 10/29/25.
//

import Foundation

/// Specifies the parameters for a link timeline request
public struct LinkTimelineQuery: Sendable, TimelineQuery {

    public init(url: String) {
        self.url = url
    }

    /// The URL of a currently trending article
    public var url: String
}

extension LinkTimelineQuery {

    public func getQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "url", value: url)
        ]
    }

}
