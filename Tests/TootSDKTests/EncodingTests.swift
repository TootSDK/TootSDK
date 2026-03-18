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

    @Test func generalEncodingOfNotificationType() async throws {
        let client = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .mastodon)
        )
        let encoder = await client.makeEncoder()
        let encoded = try encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""emoji_reaction""#.utf8))
    }

    @Test func flavorSpecificEncodingOfNotificationType() async throws {
        let client = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .pleroma)
        )
        let encoder = await client.makeEncoder()
        let encoded = try encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""pleroma:emoji_reaction""#.utf8))
    }
}
