// Created by konstantin on 22/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

struct CreateAppRequest: Hashable, Codable {
    let clientName: String
    let redirectUris: String
    let scopes: String
    let website: String
}
