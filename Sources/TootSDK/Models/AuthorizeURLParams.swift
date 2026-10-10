//
//  AuthorizeURLParams.swift
//  TootSDK
//
//  Created by Dale Price on 10/10/26.
//

import Foundation

/// Query parameters for registering the application and creating the OAuth authorization URL.
public struct AuthorizeURLParams: Codable, Hashable, Sendable {
	
	public enum OpenIDConnectPrompt: String, Hashable, Sendable, Codable {
		/// Require the user to log in again. If they are already logged in, they will be asked to log out first.
		case login
		/// Enter the signup flow instead of login. If the user is already logged in, they will be asked to log out first.
		case create
	}
	
    /// Forces the user to re-login, which is necessary for authorizing multiple accounts from the same instance.
    public var forceLogin: Bool?
    /// The ISO 639-1 two-letter language code to use while rendering the authorization form.
    public var languageCode: String?
    /// OpenID Connect `prompt`.
    ///
    /// Servers may specify whether they support this using ``InstanceV2/Registrations/oauth``, which you can obtain by calling ``TootClient/getInstanceInfo()``.
	///
	/// If ``InstanceV2/Registrations/oauth`` is `true`, the server supports at least ``OpenIDConnectPrompt/login`` and ``OpenIDConnectPrompt/create``.
    public var prompt: OpenEnum<OpenIDConnectPrompt>?
    /// Invitation code, to be used with `prompt: .create` when following an invitation to sign up.
    public var inviteCode: String?
    
    public init(forceLogin: Bool? = nil, languageCode: String? = nil, prompt: OpenEnum<OpenIDConnectPrompt>?, inviteCode: String? = nil) {
        self.forceLogin = forceLogin
        self.languageCode = languageCode
        self.prompt = prompt
        self.inviteCode = inviteCode
    }
    
    public init(forceLogin: Bool? = nil, languageCode: String? = nil, prompt: OpenIDConnectPrompt? = nil, inviteCode: String? = nil) {
        self.init(
            forceLogin: forceLogin,
            languageCode: languageCode,
            prompt: prompt != nil ? OpenEnum.some(prompt!) : nil,
            inviteCode: inviteCode
        )
    }
}
