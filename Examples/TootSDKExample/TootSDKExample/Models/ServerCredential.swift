//
//  ServerCredential.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import Foundation
import SwiftData

@Model
// A model to hold credentials
// WARNING: For a production use case, this should be stored securely in Keychain or similar
final class ServerCredential {
    @Attribute(.unique)
    var host: String
    var accessToken: String

    init(host: String, accessToken: String) {
        self.host = host
        self.accessToken = accessToken
    }
}
