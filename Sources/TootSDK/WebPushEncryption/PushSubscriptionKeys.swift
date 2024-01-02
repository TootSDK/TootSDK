//
//  PushSubscriptionKeys.swift
//
//
//  Created by Łukasz Rutkowski on 02/01/2024.
//

import Foundation
import Crypto

extension WebPushMessageEncryption {

    /// Helper to generate encryption data required by Web Push API.
    ///
    /// - Important: Make sure to persist generated private key and auth secret in secure storage like keychain.
    public struct Keys {
        /// User agent private key.
        public let privateKey: P256.KeyAgreement.PrivateKey

        /// Auth secret as 16 bytes of random data.
        public let auth: Data
        
        /// The corresponding user agent public key.
        public var publicKey: P256.KeyAgreement.PublicKey {
            privateKey.publicKey
        }

        public init(privateKey: P256.KeyAgreement.PrivateKey, auth: Data) {
            self.privateKey = privateKey
            self.auth = auth
        }

        /// Generates a new private key and auth secret.
        public static func new() -> Keys {
            return Keys(
                privateKey: .init(),
                auth: newAuthSecret()
            )
        }

        /// Returns a new randomly generated auth secret.
        public static func newAuthSecret() -> Data {
            Data((0..<16).map { _ in UInt8.random(in: UInt8.min...UInt8.max) })
        }
    }
}
