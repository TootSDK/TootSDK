//
//  WebPushMessageEncryptionTests.swift
//
//
//  Created by Łukasz Rutkowski on 30/12/2023.
//

import Crypto
import Foundation
import TootSDK
import XCTest

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

    func testAuthSecretLength() throws {
        let authSecret = WebPushMessageEncryption.Keys.newAuthSecret()
        XCTAssertEqual(authSecret.count, 16)
    }

    func testDecryptAndDecode() throws {
        let encryptedMessageString = try XCTUnwrap(String(data: localContent("encrypted_push_notification", "base64"), encoding: .utf8))
        let encryptedMessage = try decode(encryptedMessageString)
        let privateKeyData = try decode(
            "BF1sQLyEbj_Q2w9Gr7CxULMW0dXT5ieNqfNW_SHnilFLf938diBugHck3W2xf3dTUC93J0yPv8_a79qQ-AbfStlVgbJLWlzK4MFXqFGJRYX6wVOoHsmRr36B11LrtN0dJQ")
        let privateKey = try P256.KeyAgreement.PrivateKey(x963Representation: privateKeyData)
        let serverPublicKeyData = try decode("BFbMjBuONvogk0Z5gdaPYx1hshYTfoc7eoMHjaPpGspYTfzdba8KMaXJGew63nD7S9ttnGl-hys_VlTxjnGUCZQ")
        let serverPublicKey = try P256.KeyAgreement.PublicKey(x963Representation: serverPublicKeyData)
        let auth = try decode("ouXXmgTzIc17NYAqxZw8Yw")
        let salt = try decode("2tTt38nDpGXNKXTCRydTLg")

        let pushNotification = try WebPushMessageEncryption.decryptAndDecodePush(
            encryptedMessage,
            privateKey: privateKey,
            serverPublicKey: serverPublicKey,
            auth: auth,
            salt: salt
        )
        XCTAssertEqual(pushNotification.accessToken, "c43ecb5528e95f52529ec5fcf03e02966bce3602ff0017bea98a83136df70485")
        XCTAssertEqual(pushNotification.body, "Test")
        XCTAssertEqual(pushNotification.title, "Pipilo Test Account liked your comment on \"Test\"")
        XCTAssertEqual(pushNotification.icon, "")
        XCTAssertEqual(pushNotification.notificationId, 522903)
        XCTAssertEqual(pushNotification.notificationType, .favourite)
        XCTAssertEqual(pushNotification.preferredLocale, "en-gb")
    }

    func testEncodeKeys() throws {
        let privateKeyData = try decode("9FWl15_QUQAWDaD3k3l50ZBZQJ4au27F1V4F0uLSD_M")
        let urlSafeBase64EncodedAuth = "R29vIGdvbyBnJyBqb29iIQ"
        let auth = try decode("R29vIGdvbyBnJyBqb29iIQ")
        let privateKey = try P256.KeyAgreement.PrivateKey(rawRepresentation: privateKeyData)
        let encryptionKeys = WebPushMessageEncryption.Keys(privateKey: privateKey, auth: auth)
        let keys = PushSubscriptionParams.Keys(encryptionKeys)
        XCTAssertEqual(keys.p256dh, "BCEkBjzL8Z3C-oi2Q7oE5t2Np-p7osjGLg93qUP0wvqRT21EEWyf0cQDQcakQMqz4hQKYOQ3il2nNZct4HgAUQU")
        XCTAssertEqual(keys.auth, urlSafeBase64EncodedAuth)
    }

    private func decode(_ base64UrlEncoded: String) throws -> Data {
        return try XCTUnwrap(Data(urlSafeBase64Encoded: base64UrlEncoded))
    }
}
