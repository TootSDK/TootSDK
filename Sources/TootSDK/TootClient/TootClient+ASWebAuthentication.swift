// Created by david-hosier on 07/02/2023
// Copyright (c) 2023. All rights reserved.

#if canImport(AuthenticationServices) && !os(tvOS) && !os(watchOS)

    import AuthenticationServices
    import Foundation

    extension TootClient {

        /// Presents a authentication/authorization page using ASWebAuthenticationSession.
        /// When signIn is initiated on supported platforms, the authorization web page will be presented in a system-dependent manner that negates the need for user's to implement a custom web view. Upon successful authentication (or cancellation), control will be return to this function to handle token retrieval.
        ///
        /// - Parameters:
        ///   - callbackURI: The callback URI  (`redirect_uri`) which was used to initiate the authorization flow. Must match one of the redirect_uris declared during app registration.
        ///   - prefersEphemeralWebBrowserSession: A Boolean value that indicates whether the session should ask the browser for a private authentication session.
        ///   - presentationContextProvider: A delegate that provides a display context in which the system can present an authentication session to the user.
        /// - Returns: The auth token for the user if authentication succeeds.
        @MainActor public func presentSignIn(
            callbackURI: String,
            prefersEphemeralWebBrowserSession: Bool = true,
            presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
        ) async throws -> String {
            
            guard
                let callbackURLScheme: String = URL(string: callbackURI)?.scheme
            else {
                throw TootSDKError.unexpectedError("Unable to retrieve scheme from callbackURI")
            }

            let authUrl = try await createAuthorizeURL(callbackURI: callbackURI)

            let returnedUrl: URL = try await withCheckedThrowingContinuation { continuation in
                let authSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: callbackURLScheme) { (url, error) in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    if let url = url {
                        return continuation.resume(returning: url)
                    }
                    return continuation.resume(
                        throwing: TootSDKError.unexpectedError(
                            "There was a problem authenticating the user: no URL was returned from the first authentication step."))
                }

                authSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
                authSession.start()
            }

            return try await collectToken(
                returnUrl: returnedUrl,
                callbackURI: callbackURI)
        }
    }

#endif
