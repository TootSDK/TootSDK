// Created by konstantin on 17/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public struct PleromaOauthApp: Codable, Identifiable {
    public var id: Int
    /// Application Name
    public var name: String?
    public var clientId: String?
    public var clientSecret: String?
    /// Where the user is to be redirected after authorization. A value of urn:ietf:wg:oauth:2.0:oob means the user will be given an authorization code instead of a redirect.
    public var redirectUri: String?
    
    /// Is the app trusted?
    public var trusted: Bool?
    
    /// A URL to the homepage of the app
    public var website: String?
    /// oAuth scopes
    public var scopes: [String]?
    
    public init(id: Int, name: String? = nil, clientId: String? = nil, clientSecret: String? = nil, redirectUri: String? = nil, trusted: Bool? = nil, website: String? = nil, scopes: [String]? = nil) {
        self.id = id
        self.name = name
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.trusted = trusted
        self.website = website
        self.scopes = scopes
    }
}
