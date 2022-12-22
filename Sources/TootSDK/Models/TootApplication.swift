// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Represents an application that interfaces with the REST API to access accounts or posts.
public struct TootApplication: Codable, Hashable {
    public init(name: String,
                website: String? = nil,
                vapidKey: String? = nil,
                redirectUri: String? = nil,
                clientId: String? = nil,
                clientSecret: String? = nil,
                id: String? = nil) {
        self.name = name
        self.website = website
        self.vapidKey = vapidKey
        self.redirectUri = redirectUri
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.id = id
    }

    /// The name of your application.
    public var name: String
    ///  The website associated with your application.
    public var website: String?
    /// Used for Push Streaming API. Returned with POST /api/v1/apps. Equivalent to PushSubscription#server_key
    public var vapidKey: String?

    // MARK: - client attributes
    public var redirectUri: String?
    /// Client ID key, to be used for obtaining OAuth tokens
    public var clientId: String?
    /// Client secret key, to be used for obtaining OAuth tokens
    public var clientSecret: String?

    // MARK: - registration
    public var id: String?
}
