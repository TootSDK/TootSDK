//
//  AnnouncementParams.swift
//  
//
//  Created by Philip Chu on 11/19/23.
//

import Foundation

public struct AnnouncementParams: Codable, Sendable {
    
    /// If true, response will include announcements dismissed by the user. Defaults to false
    public var withDismissed: Bool?

    public init(withDismissed: Bool? = nil) {
        self.withDismissed = withDismissed
    }
}

extension AnnouncementParams {
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "with_dismissed",
                         value: withDismissed?.description),
        ].filter { $0.value != nil }
    }
}

