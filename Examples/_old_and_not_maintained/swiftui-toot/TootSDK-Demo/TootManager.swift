//
//  TootManager.swift
//  SwiftUI-Toot
//
//  Created by dave on 7/11/22.
//

import AuthenticationServices
import Combine
import Foundation
import SwiftKeychainWrapper
import TootSDK

/// Holder class for managing your currently selected client
public class TootManager: ObservableObject, @unchecked Sendable {
    private var instanceKey = "tootSDK.instanceURL"
    private var accessTokenKey = "tootSDK.accessToken"
    private let callbackURI = "swiftuitoot://test"

    // MARK: - Published properties
    @Published public var currentClient: TootClient!
    @Published public var authenticated: Bool = false

    init() {
        if let instanceURLstring = KeychainWrapper.standard.string(forKey: self.instanceKey),
            let instanceURL = URL(string: instanceURLstring),
            let accessToken = KeychainWrapper.standard.string(forKey: self.accessTokenKey)
        {

            self.currentClient = TootClient(instanceURL: instanceURL, accessToken: accessToken)
            self.currentClient?.debugOn()
            self.authenticated = true
            Task {
                try await self.currentClient.connect()
            }
        }
    }

    @MainActor public func createClientAndPresentSignIn(_ url: URL) async throws {
        self.currentClient = try await TootClient(connect: url)

        if let accessToken = try await currentClient?.presentSignIn(callbackURI: callbackURI) {
            if let instanceURL = currentClient?.instanceURL {
                KeychainWrapper.standard.set(instanceURL.absoluteString, forKey: self.instanceKey)
                KeychainWrapper.standard.set(accessToken, forKey: self.accessTokenKey)
                authenticated = true
            }
        }
    }

    @MainActor public func createClientAndAuthorizeURL(_ url: URL) async throws -> URL? {
        self.currentClient = try await TootClient(connect: url)

        return try await self.currentClient?.createAuthorizeURL(server: url, callbackURI: callbackURI)
    }

    @MainActor public func collectAccessToken(_ url: URL) async throws {
        if let accessToken = try await currentClient?.collectToken(returnUrl: url, callbackURI: callbackURI) {

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
