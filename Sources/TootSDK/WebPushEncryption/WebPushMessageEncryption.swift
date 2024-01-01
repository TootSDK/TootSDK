//
//  WebPushMessageEncryption.swift
//  
//
//  Created by Łukasz Rutkowski on 30/12/2023.
//

import Foundation
import Crypto

/// Helper for Web Push message handling.
public enum WebPushMessageEncryption {
    
    /// Decrypts and decodes a push notification.
    ///
    /// - Parameters:
    ///   - encryptedMessage: The encrypted message data received in push.
    ///   - privateKey: The private key corresponding to a public key used when registering push subscription.
    ///   - serverPublicKey: The public key of a server received in push  as "dh" parameter of "Crypto-Key" HTTP header
    ///   - auth: The authentication secret used when registering push subscription.
    ///   - salt: The salt received from server in push  as "salt" parameter of "Encryption" HTTP header.
    /// - Returns: Push notification.
    public static func decryptAndDecodePush(
        _ encryptedMessage: Data,
        privateKey: P256.KeyAgreement.PrivateKey,
        serverPublicKey: P256.KeyAgreement.PublicKey,
        auth: Data,
        salt: Data
    ) throws -> PushNotification {
        let decryptedMessageData = try decrypt(
            encryptedMessage,
            privateKey: privateKey,
            serverPublicKey: serverPublicKey,
            auth: auth,
            salt: salt
        )
        return try TootDecoder().decode(PushNotification.self, from: decryptedMessageData)
    }

    /// Decrypts a message encrypted by server according to Web Push standard.
    ///
    /// - Reference:
    ///   - [Message Encryption for Web Push](https://datatracker.ietf.org/doc/html/draft-ietf-webpush-encryption-04)
    ///   - [ecec](https://github.com/web-push-libs/ecec?tab=readme-ov-file#ecec)
    ///
    /// - Parameters:
    ///   - encryptedMessage: The encrypted message data received in push.
    ///   - privateKey: The private key corresponding to a public key used when registering push subscription.
    ///   - serverPublicKey: The public key of a server received in push  as "dh" parameter of "Crypto-Key" HTTP header
    ///   - auth: The authentication secret used when registering push subscription.
    ///   - salt: The salt received from server in push  as "salt" parameter of "Encryption" HTTP header.
    /// - Returns: Decrypted message data.
    public static func decrypt(
        _ encryptedMessage: Data,
        privateKey: P256.KeyAgreement.PrivateKey,
        serverPublicKey: P256.KeyAgreement.PublicKey,
        auth: Data,
        salt: Data
    ) throws -> Data {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)

        var context = Array("P-256".utf8)
        context.append(0)

        // Public key: length (UInt16) + data
        let publicKeyData = privateKey.publicKey.x963Representation
        context.append(0)
        context.append(UInt8(publicKeyData.count))
        context.append(contentsOf: publicKeyData)

        // Server public key: length (UInt16) + data
        let serverPublicKeyData = serverPublicKey.x963Representation
        context.append(0)
        context.append(UInt8(serverPublicKeyData.count))
        context.append(contentsOf: serverPublicKeyData)

        let pseudoRandomKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: auth,
            sharedInfo: info("auth", context: []),
            outputByteCount: 32
        )
        let key = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: pseudoRandomKey,
            salt: salt,
            info: info("aesgcm", context: context),
            outputByteCount: 16
        )
        let nonce = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: pseudoRandomKey,
            salt: salt,
            info: info("nonce", context: context),
            outputByteCount: 12
        )
        let nonceData = nonce.withUnsafeBytes(Array.init)

        let sealedBox = try AES.GCM.SealedBox(combined: nonceData + encryptedMessage)
        let plaintext = try AES.GCM.open(sealedBox, using: key)

        let paddingLength = Int(plaintext[0]) * 256 + Int(plaintext[1])
        guard plaintext.count >= 2 + paddingLength else {
            throw TootSDKError.unexpectedError("Malformed encoded message. Padding should not be longer than message.")
        }
        let unpadded = plaintext.suffix(from: paddingLength + 2)

        return Data(unpadded)
    }

    private static func info(_ name: String, context: [UInt8]) -> [UInt8] {
        return Array("Content-Encoding: \(name)\0".utf8) + context
    }
}
