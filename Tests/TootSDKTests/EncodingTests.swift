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

    @Test func generalEncodingOfNotificationType() throws {
        let client = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .mastodon)
        )
        let encoded = try client.encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""emoji_reaction""#.utf8))
    }

    @Test func flavorSpecificEncodingOfNotificationType() throws {
        let client = TootClient(
            instanceURL: URL(string: "https://mastodon.social")!,
            serverConfiguration: ServerConfiguration(flavour: .pleroma)
        )
        let encoded = try client.encoder.encode(TootNotification.NotificationType.emojiReaction)
        #expect(encoded == Data(#""pleroma:emoji_reaction""#.utf8))
    }
}
