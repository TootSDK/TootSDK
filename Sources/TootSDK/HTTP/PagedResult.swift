// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct PagedResult<T: Decodable>: Decodable {
    public let result: T
    public let info: PagedInfo
}

extension PagedResult {
    /// Returns `true` if the paged result has a next page of results. A next page contains results newer than the current page.
    public var hasNext: Bool {
        info.sinceId != nil || info.minId != nil
    }

    /// Returns `true` if the paged result has a previous page of results. A next page contains results older than the current page.
    public var hasPrevious: Bool {
        info.maxId != nil
    }

    /// Returns pagination object for the next page of results if one is available
    public var nextPage: PagedInfo? {
        if let sinceId = info.sinceId {
            return PagedInfo(sinceId: sinceId)
        }
        if let minId = info.minId {
            return PagedInfo(minId: minId)
        }
        return nil
    }

    /// Returns pagination object for the previous page of results if one is available
    public var previousPage: PagedInfo? {
        if let maxId = info.maxId {
            return PagedInfo(maxId: maxId)
        }
        return nil
    }
}
