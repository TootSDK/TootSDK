// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct PagedResult<T: Decodable>: Decodable {
    public let result: T
    public let info: PagedInfo

    /// Returns pagination object for the next page of results if one is available. A next page contains results newer than the current page.
    public let nextPage: PagedInfo?

    /// Returns pagination object for the previous page of results if one is available.  A previous page contains results older than the current page.
    public let previousPage: PagedInfo?
}

extension PagedResult {
    /// Returns `true` if the paged result has a next page of results. A next page contains results newer than the current page.
    public var hasNext: Bool {
        nextPage != nil
    }

    /// Returns `true` if the paged result has a previous page of results. A previous page contains results older than the current page.
    public var hasPrevious: Bool {
        previousPage != nil
    }
}
