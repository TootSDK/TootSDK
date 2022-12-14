// Created by konstantin on 30/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct PagedInfo: Decodable {
  public init(maxId: String? = nil, minId: String? = nil, sinceId: String? = nil) {
    self.maxId = maxId
    self.minId = minId
    self.sinceId = sinceId
  }

  /// Return results older than ID.
  public let maxId: String?
  /// Return results immediately newer than ID.
  public let minId: String?
  /// Return results newer than ID.
  public let sinceId: String?
}

public extension PagedInfo {
    var isPaged: Bool {
        return self.maxId != nil || self.minId != nil || self.sinceId != nil
    }
}
