// Created by konstantin on 17/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Parameters to retrieve a list of oauth apps
public struct ListOauthAppsParams: Codable {
    
    /// App name
    var name: String?
    
    /// Client ID
    var clientId: String?
    
    /// Trusted apps, defaults to false
    var trusted: Bool?
    
    /// Number of apps to return, defaults to 50.
    var pageSize: Int?
    
    /// Allows authorization via admin token.
    var adminToken: String?
    
    public init(name: String? = nil, clientId: String? = nil, trusted: Bool? = nil, pageSize: Int? = nil, adminToken: String? = nil) {
        self.name = name
        self.clientId = clientId
        self.trusted = trusted
        self.pageSize = pageSize
        self.adminToken = adminToken
    }
}
