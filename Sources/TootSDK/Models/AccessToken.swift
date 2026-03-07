// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct AccessToken: Codable, Sendable {
    public let scope: String?
    public let tokenType: String?
    public let accessToken: String?
}
