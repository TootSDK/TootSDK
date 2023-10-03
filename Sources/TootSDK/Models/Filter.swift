// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct Filter: Codable, Hashable, Identifiable {
    public enum Context: String, Codable {
        /// home timeline and lists
        case home
        /// notifications timeline
        case notifications
        /// public timelines
        case `public`
        /// expanded thread of a detailed status
        case thread
        /// when viewing a profile
        case account
    }

    public enum Action: String, Codable {
        /// show a warning that identifies the matching filter by title, and allow the user to expand the filtered status. This is the default (and unknown values should be treated as equivalent to warn).
        case warn
        /// do not show this status if it is received
        case hide
    }

    /// The ID of the Filter in the database.
    public var id: String
    /// A title given by the user to name the filter.
    public var title: String
    /// The contexts in which the filter should be applied.
    public var context: [Context]
    /// When the filter should no longer be applied.
    public var expiresAt: Date?
    /// The action to be taken when a status matches this filter.
    public var filterAction: Action
    /// The keywords grouped under this filter.
    public var keywords: [FilterKeyword]
    /// The statuses grouped under this filter.
    public var statuses: [FilterStatus]
}

extension Filter.Context: Identifiable {
    public var id: Self { self }
}
