// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Filter: Codable, Hashable, Identifiable {
    public enum Context: String, Codable {
        case home
        case notifications
        case `public`
        case thread
    }

    public var id: String
    public var phrase: String
    public var context: [Context]
    public var expiresAt: Date?
    public var irreversible: Bool
    public var wholeWord: Bool
}

extension Filter.Context: Identifiable {
    public var id: Self { self }
}
