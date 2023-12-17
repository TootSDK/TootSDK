// Created by konstantin on 19/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct RemoveAccountsFromListParams: Codable {
    public init(accountIds: [String]) {
        self.accountIds = accountIds
    }

    /// The accounts that should be added to the list.
    public var accountIds: [String]
}

extension RemoveAccountsFromListParams {
    public init(accountId: String) {
        self = RemoveAccountsFromListParams(accountIds: [accountId])
    }
}
