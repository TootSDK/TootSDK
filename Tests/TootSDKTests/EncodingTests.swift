//
//  Test.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 03/08/2025.
//

import Testing
@testable import TootSDK
import Foundation

struct EncodingTests {

    private let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)

    @Test func generalEncodingOfNotificationType() throws {
        client.flavour = .mastodon
        let encoded = try client.encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""emoji_reaction""#.utf8))
    }

    @Test func flavorSpecificEncodingOfNotificationType() throws {
        client.flavour = .pleroma
        let encoded = try client.encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""pleroma:emoji_reaction""#.utf8))
    }
}
