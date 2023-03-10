//
//  RegisterAccountParams.swift
//  
//
//  Created by Konstantin on 09/03/2023.
//

import Foundation

public struct RegisterAccountParams: Codable, Sendable {
    public init(username: String, email: String, password: String, agreement: String, locale: String, reason: String? = nil, token: String? = nil, fullname: String? = nil, captchaSolution: String? = nil, captchaToken: String? = nil, captchaAnswerData: String? = nil) {
        self.username = username
        self.email = email
        self.password = password
        self.agreement = agreement
        self.locale = locale
        self.reason = reason
        self.token = token
        self.fullname = fullname
        self.captchaSolution = captchaSolution
        self.captchaToken = captchaToken
        self.captchaAnswerData = captchaAnswerData
    }
    
    /// The desired username for the account
    public var username: String
    
    /// The email address to be used for login.
    public var email: String
    
    /// The password to be used for login
    public var password: String
    
    /// Whether the user agrees to the local rules, terms, and policies. These should be presented to the user in order to allow them to consent before setting this parameter to `true`.
    public var agreement: String
    
    /// The language of the confirmation email that will be sent.
    public var locale: String
    
    /// If registrations require manual approval, this text will be reviewed by moderators.
    public var reason: String?
    
    /// Invite token required when the registrations aren't public. Only supported by Pleroma and Akkoma
    public var token: String?
    
    /// Full name. Only supported by Pleroma and Akkoma
    public var fullname: String?
    
    /// Contains provider-specific captcha solution. Only supported by Pleroma and Akkoma
    public var captchaSolution: String?
    
    /// Contains provider-specific captcha token. Only supported by Pleroma and Akkoma
    public var captchaToken: String?
    
    /// Contains provider-specific captcha data. Only supported by Pleroma and Akkoma
    public var captchaAnswerData: String?
}
