//
//  Test.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 03/08/2025.
//

import Foundation
import Testing

@testable import TootSDK

struct EncodingTests {

    private let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)

    @Test func generalEncodingOfNotificationType() throws {
        client.flavour = .mastodon
        client.encoder.userInfo[.tootSDKFlavour] = client.flavour
        let encoded = try client.encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""emoji_reaction""#.utf8))
    }

    @Test func flavorSpecificEncodingOfNotificationType() throws {
        client.flavour = .pleroma
        client.encoder.userInfo[.tootSDKFlavour] = client.flavour
        let encoded = try client.encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""pleroma:emoji_reaction""#.utf8))
    }
}
