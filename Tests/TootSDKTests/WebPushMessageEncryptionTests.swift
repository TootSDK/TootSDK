//
//  WebPushMessageEncryptionTests.swift
//  
//
//  Created by Łukasz Rutkowski on 30/12/2023.
//

#if canImport(CryptoKit)
import Foundation
import XCTest
import TootSDK
import CryptoKit

final class WebPushMessageEncryptionTests: XCTestCase {
    func testDecrypt() throws {
        let encryptedMessage = try decode("6nqAQUME8hNqw5J3kl8cpVVJylXKYqZOeseZG8UueKpA")
        let privateKeyData = try decode("9FWl15_QUQAWDaD3k3l50ZBZQJ4au27F1V4F0uLSD_M")
        let privateKey = try P256.KeyAgreement.PrivateKey(rawRepresentation: privateKeyData)
        let serverPublicKeyData = try decode("BNoRDbb84JGm8g5Z5CFxurSqsXWJ11ItfXEWYVLE85Y7CYkDjXsIEc4aqxYaQ1G8BqkXCJ6DPpDrWtdWj_mugHU")
        let serverPublicKey = try P256.KeyAgreement.PublicKey(x963Representation: serverPublicKeyData)
        let auth = try decode("R29vIGdvbyBnJyBqb29iIQ")
        let salt = try decode("lngarbyKfMoi9Z75xYXmkg")

        let decryptedMessageData = try WebPushMessageEncryption.decrypt(
            encryptedMessage,
            privateKey: privateKey,
            serverPublicKey: serverPublicKey,
            auth: auth,
            salt: salt
        )
        let decryptedMessage = try XCTUnwrap(String(data: decryptedMessageData, encoding: .utf8))
        XCTAssertEqual(decryptedMessage, "I am the walrus")
    }

    private func decode(_ base64UrlEncoded: String) throws -> Data {
        return try XCTUnwrap(Data(urlSafeBase64Encoded: base64UrlEncoded))
    }
}
#endif
