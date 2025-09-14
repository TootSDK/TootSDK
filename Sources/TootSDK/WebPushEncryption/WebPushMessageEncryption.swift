//
//  WebPushMessageEncryption.swift
//
//  Provides encryption and decryption helpers for Web Push messages.
//
//  Created by Łukasz Rutkowski on 30/12/2023.
//

import Crypto
import Foundation

/// Helper for Web Push message handling.
public enum WebPushMessageEncryption {
    /// Supported Web Push content encodings as defined in the Web Push specifications.
    public enum ContentEncoding: String {
        /// AES-GCM encoding (RFC 8291 4th draft). https://datatracker.ietf.org/doc/html/draft-ietf-webpush-encryption-04
        case aesgcm
        /// AES-128-GCM encoding (RFC 8291). https://datatracker.ietf.org/doc/html/rfc8291
        case aes128gcm
    }

    /// Decrypts and decodes a push notification.
    ///
    /// - Parameters:
    ///   - encryptedMessage: The encrypted message data received in push.
    ///   - privateKey: The private key corresponding to a public key used when registering push subscription.
    ///   - serverPublicKey: The server's public key received in push as the "dh" parameter of the "Crypto-Key" HTTP header.
    ///   - auth: The authentication secret used when registering push subscription.
    ///   - salt: The salt received from the server in push as the "salt" parameter of the "Encryption" HTTP header.
    ///   - encoding: The content encoding algorithm to use.
    /// - Returns: Push notification.
    public static func decryptAndDecodePush(
        _ encryptedMessage: Data,
        privateKey: P256.KeyAgreement.PrivateKey,
        serverPublicKey: P256.KeyAgreement.PublicKey?,
        auth: Data,
        salt: Data?,
        encoding: ContentEncoding
    ) throws -> PushNotification {
        let decryptedMessageData = try decrypt(
            encryptedMessage,
            privateKey: privateKey,
            serverPublicKey: serverPublicKey,
            auth: auth,
            salt: salt,
            encoding: encoding
        )
        return try TootDecoder().decode(PushNotification.self, from: decryptedMessageData)
    }

    /// Decrypts a message encrypted by server according to Web Push standard.
    ///
    /// - Parameters:
    ///   - encryptedMessage: The encrypted message data received in push.
    ///   - privateKey: The private key corresponding to a public key used when registering push subscription.
    ///   - serverPublicKey: The server's public key received in push as the "dh" parameter of the "Crypto-Key" HTTP header. Used for `aesgcm` encoding only.
    ///   - auth: The authentication secret used when registering push subscription.
    ///   - salt: The salt received from the server in push as the "salt" parameter of the "Encryption" HTTP header.  Used for `aesgcm` encoding only.
    ///   - encoding: The content encoding algorithm to use.
    /// - Returns: Decrypted message data.
    public static func decrypt(
        _ encryptedMessage: Data,
        privateKey: P256.KeyAgreement.PrivateKey,
        serverPublicKey: P256.KeyAgreement.PublicKey?,
        auth: Data,
        salt: Data?,
        encoding: ContentEncoding
    ) throws -> Data {
        switch encoding {
        case .aesgcm:
            guard let serverPublicKey else {
                throw TootSDKError.invalidParameter(
                    parameterName: "serverPublicKey",
                    reason: "Public key is required when decrypting AES-GCM encrypted messages."
                )
            }
            guard let salt else {
                throw TootSDKError.invalidParameter(parameterName: "salt", reason: "Salt is required when decrypting AES-GCM encrypted messages.")
            }
            return try decrypt(
                encryptedMessage,
                privateKey: privateKey,
                serverPublicKey: serverPublicKey,
                auth: auth,
                salt: salt
            )

        case .aes128gcm:
            return try decrypt(
                encryptedMessage,
                privateKey: privateKey,
                auth: auth
            )
        }
    }

    // MARK: AES-GCM

    /// Decrypts a message encrypted by server according to Web Push standard using AES-GCM encoding (RFC 8291 4th draft).
    ///
    /// - Parameters:
    ///   - encryptedMessage: The encrypted message data received in push.
    ///   - privateKey: The private key corresponding to a public key used when registering push subscription.
    ///   - serverPublicKey: The server's public key received in push as the "dh" parameter of the "Crypto-Key" HTTP header.
    ///   - auth: The authentication secret used when registering push subscription.
    ///   - salt: The salt received from the server in push as the "salt" parameter of the "Encryption" HTTP header.
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
        return try removeLeadingPadding(plaintext)
    }

    private static func removeLeadingPadding(_ data: Data) throws -> Data {
        let paddingLength = Int(data[0]) * 256 + Int(data[1])
        guard data.count >= 2 + paddingLength else {
            throw TootSDKError.unexpectedError("Malformed encoded message. Padding should not be longer than message.")
        }
        let unpadded = data.suffix(from: paddingLength + 2)
        return Data(unpadded)
    }

    private static func info(_ name: String, context: [UInt8]?) -> [UInt8] {
        let bytes = Array("Content-Encoding: \(name)\0".utf8)
        if let context {
            return bytes + context
        }
        return bytes
    }

    // - MARK: AES-128-GCM

    /// Decrypts a message encrypted by server according to Web Push standard using AES-128-GCM encoding (RFC 8291).
    ///
    /// - Parameters:
    ///   - encryptedMessageWithHeader: The encrypted message data received in push.
    ///   - privateKey: The private key corresponding to a public key used when registering push subscription.
    ///   - auth: The authentication secret used when registering push subscription.
    /// - Returns: Decrypted message data.
    public static func decrypt(
        _ encryptedMessageWithHeader: Data,
        privateKey: P256.KeyAgreement.PrivateKey,
        auth: Data
    ) throws -> Data {
        guard encryptedMessageWithHeader.count > headerKeyIDLengthEnd else {
            throw TootSDKError.unexpectedError("Encrypted message is too short.")
        }

        let salt = encryptedMessageWithHeader[headerSaltStart..<headerSaltEnd]

        let recordSize: UInt32 = encryptedMessageWithHeader[headerSaltEnd..<headerRecordSizeEnd]
            .withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        guard recordSize >= 18 else {
            throw TootSDKError.unexpectedError("Invalid record size")
        }

        let keyIDLength: UInt8 = encryptedMessageWithHeader[headerKeyIDLengthStart]
        let headerKeyIDEnd = Int(keyIDLength) + headerKeyIDStart
        let serverPublicKeyData = encryptedMessageWithHeader[headerKeyIDStart..<headerKeyIDEnd]
        let encryptedMessage = encryptedMessageWithHeader[headerKeyIDEnd...]

        let serverPublicKey = try P256.KeyAgreement.PublicKey(x963Representation: serverPublicKeyData)
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)

        var keyInfo = Array("WebPush: info\0".utf8)
        keyInfo.append(contentsOf: privateKey.publicKey.x963Representation)
        keyInfo.append(contentsOf: serverPublicKey.x963Representation)

        let pseudoRandomKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: auth,
            sharedInfo: keyInfo,
            outputByteCount: 32
        )
        let key = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: pseudoRandomKey,
            salt: salt,
            info: info("aes128gcm", context: nil),
            outputByteCount: 16
        )
        let nonce = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: pseudoRandomKey,
            salt: salt,
            info: info("nonce", context: nil),
            outputByteCount: 12
        )
        let nonceData = nonce.withUnsafeBytes(Array.init)

        let sealedBox = try AES.GCM.SealedBox(combined: nonceData + encryptedMessage)
        let plaintext = try AES.GCM.open(sealedBox, using: key)
        return try removeTrailingPadding(plaintext)
    }

    private static func removeTrailingPadding(_ data: Data) throws -> Data {
        var byteIndex = data.count - 1
        while byteIndex >= 0 && data[byteIndex] == 0 {
            byteIndex -= 1
        }
        guard
            byteIndex >= 0,
            data[byteIndex] == lastRecordPaddingDelimiter
        else {
            throw TootSDKError.unexpectedError("Invalid padding")
        }
        let unpadded = data.prefix(byteIndex)
        return Data(unpadded)
    }

    private static let headerSaltStart = 0
    private static let headerSaltEnd = 16 + headerSaltStart
    private static let headerRecordSizeStart = headerSaltEnd
    private static let headerRecordSizeEnd = 4 + headerRecordSizeStart
    private static let headerKeyIDLengthStart = headerRecordSizeEnd
    private static let headerKeyIDLengthEnd = 1 + headerKeyIDLengthStart
    private static let headerKeyIDStart = headerKeyIDLengthEnd
    private static let lastRecordPaddingDelimiter = 2
}
