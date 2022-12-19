// Created by konstantin on 17/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public extension TootClient {
    
    /// Retrieve a list of OAuth applications
    ///
    /// * This method requires the `admin:write` scope.
    /// * This method requires the pleroma API flavour.
    func adminGetOauthApps(_ page: Int = 1, params: ListOauthAppsParams? = nil) async throws -> [PleromaOauthApp]? {
        guard flavour == .pleroma else {
            throw TootSDKError.unsupportedFlavour(current: flavour, required: [.pleroma])
        }
        
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "pleroma", "admin", "oauth_app"])
            $0.method = .get
            $0.addQueryParameter(name: "page", value: "\(page)")
        }
        
        if let name = params?.name {
            req.addQueryParameter(name: "name", value: name)
        }
        
        if let clientId = params?.clientId {
            req.addQueryParameter(name: "client_id", value: clientId)
        }
        
        if let trusted = params?.trusted {
            req.addQueryParameter(name: "trusted", value: "\(trusted)")
        }
        
        if let pageSize = params?.pageSize {
            req.addQueryParameter(name: "page_size", value: "\(pageSize)")
        }
        
        if let adminToken = params?.adminToken {
            req.addQueryParameter(name: "admin_token", value: "\(adminToken)")
        }
        
        let response = try await fetch(PleromaOauthAppsResponse.self, req)
        return response?.apps ?? []
    }
    
    /// Delete OAuth application
    ///
    /// * This method requires the `admin:write` scope.
    /// * This method requires the pleroma API flavour.
    func adminDeleteOauthApp(appId: Int) async throws {
        if ![TootSDKFlavour.pleroma].contains(flavour) {
            throw TootSDKError.unsupportedFlavour(current: flavour, required: [.pleroma])
        }
        
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "pleroma", "admin", "oauth_app", "\(appId)"])
            $0.method = .delete
        }
        
        _ = try await fetch(req: req)
    }
}
