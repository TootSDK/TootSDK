// Created by konstantin on 17/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct PleromaOauthAppsResponse: Codable, Sendable {
    var apps: [PleromaOauthApp]
    var count: Int?
    var pageSize: Int?
}
