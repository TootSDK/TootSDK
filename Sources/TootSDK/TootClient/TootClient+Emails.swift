//
//  TootClient+Emails.swift
//  TootSDK
//
//  Created by Dale Price on 10/12/26.
//

import Foundation

extension TootClient {
    /// Resend a new confirmation email. If an email is provided, updates the unconfirmed user’s email before resending the confirmation email.
    /// - Parameter emailAddress: If provided, updates the unconfirmed user’s email before resending the confirmation email.
    public func resendConfirmationEmail(emailAddress: String? = nil) async throws {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "emails", "confirmations"])
            $0.method = .post
            if let emailAddress {
                $0.body = try .form(queryItems: [
                    URLQueryItem(name: "email", value: emailAddress)
                ])
            }
        }
        _ = try await fetch(req: req)
    }
}
