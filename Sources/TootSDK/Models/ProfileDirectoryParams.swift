//
//  ProfileDirectoryParams.swift
//
//
//  Created by Philip Chu on 5/29/23.
//

import Foundation

public struct ProfileDirectoryParams: Codable {

    /// Use active to sort by most recently posted statuses (default) or new to sort by most recently created profiles.
    public var order: Order?
    /// If true, returns only local accounts.
    public var local: Bool?

    public init(order: Order? = nil,
                local: Bool? = nil) {
        self.order = order
        self.local = local
    }

    public enum Order: String, Codable, Hashable, CaseIterable {
        case active
        case new
    }
}

extension ProfileDirectoryParams {
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "order", value: order?.rawValue),
            URLQueryItem(name: "local", value: local?.description)
        ].filter { $0.value != nil }
    }
}
