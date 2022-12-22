// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct PagedResult<T: Decodable>: Decodable {
    public let result: T
    public let info: PagedInfo
}
