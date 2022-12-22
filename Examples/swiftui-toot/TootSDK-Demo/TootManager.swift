//
//  TootManager.swift
//  SwiftUI-Toot
//
//  Created by dave on 7/11/22.
//

import Foundation
import TootSDK
import SwiftKeychainWrapper

/// Holder class for managing your currently selected client
public class TootManager: ObservableObject {
    private var instanceKey = "tootSDK.instanceURL"
    private var accessTokenKey = "tootSDK.accessToken"
    private let callbackUrl = "swiftuitoot://test"
    
    // MARK: - Published properties
    @Published public var currentClient: TootClient!
    @Published public var authenticated: Bool = false
    
    init() {
        if let instanceURLstring = KeychainWrapper.standard.string(forKey: self.instanceKey),
           let instanceURL = URL(string: instanceURLstring),
           let accessToken = KeychainWrapper.standard.string(forKey: self.accessTokenKey) {
            
            self.currentClient = TootClient(instanceURL: instanceURL, accessToken: accessToken)
            self.currentClient?.debugOn()
            self.authenticated = true
        }
    }
    
    @MainActor public func createClientAndAuthorizeURL(_ url: URL) async throws -> URL? {
        self.currentClient = TootClient(instanceURL: url)
        
        return try await self.currentClient?.createAuthorizeURL(server: url, callbackUrl: callbackUrl)
    }
    
    @MainActor public func collectAccessToken(_ url: URL) async throws {
        if let accessToken = try await currentClient?.collectToken(returnUrl: url, callbackUrl: callbackUrl) {
            
            // Persist token and instance details for signing in
            if let instanceURL = currentClient?.instanceURL {
                KeychainWrapper.standard.set(instanceURL.absoluteString, forKey: self.instanceKey)
                KeychainWrapper.standard.set(accessToken, forKey: self.accessTokenKey)
                authenticated = true
            }
        }
    }
    
    @MainActor public func signOut() {
        KeychainWrapper.standard.removeAllKeys()
        authenticated = false
        self.currentClient = nil
    }
    
}
