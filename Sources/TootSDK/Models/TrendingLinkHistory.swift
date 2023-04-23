//
//  TrendingLinkHistory.swift
//
//
//  Created by Dale Price on 4/11/23.
//

import Foundation

public extension TrendingLink {
    /// Represents daily usage history of a link.
    struct History: Codable, Hashable, Sendable {
        public init(day: String,
                    uses: String,
                    accounts: String) {
            self.day = day
            self.uses = uses
            self.accounts = accounts
        }

        /// UNIX timestamp on midnight of the given day.
        public let day: String
        /// the counted usage of the link within that day.
        public let uses: String
        /// the total of accounts posting the link within that day.
        public let accounts: String
    }
}
