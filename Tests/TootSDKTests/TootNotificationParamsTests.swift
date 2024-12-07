//
//  TootNotificationParamsTests.swift
//
//
//  Created by Łukasz Rutkowski on 05/01/2024.
//

import Foundation
import Testing

@testable import TootSDK

@Suite struct TootNotificationParamsTests {

    private let flavoursNotSupportingTypes: [TootSDKFlavour] = [.friendica, .sharkey]

    @Test func friendicaSharkeyKeepUnchanged_whenNothingSpecified() throws {
        for flavour in flavoursNotSupportingTypes {
            let params = TootNotificationParams().corrected(for: flavour)
            #expect(params.excludeTypes == nil, "Incorrect exclude types for \(flavour)")
            #expect(params.types == nil, "Incorrect types for \(flavour)")
        }
    }

    @Test func friendicaSharkeyKeepUnchanged_whenOnlyExcludedTypesProvided() throws {
        for flavour in flavoursNotSupportingTypes {
            let params = TootNotificationParams(excludeTypes: [.mention]).corrected(for: flavour)
            #expect(params.excludeTypes == [.mention], "Incorrect exclude types for \(flavour)")
            #expect(params.types == nil, "Incorrect types for \(flavour)")
        }
    }

    @Test func friendicaConvertTypesToExcludeTypes_whenOnlyTypesProvided() throws {
        let flavour = TootSDKFlavour.friendica
        let params = TootNotificationParams(types: [.mention]).corrected(for: flavour)
        #expect(params.excludeTypes == [.follow, .repost, .favourite, .poll], "Incorrect exclude types for \(flavour)")
        #expect(params.types == nil, "Incorrect types for \(flavour)")
    }

    @Test func sharkeyConvertTypesToExcludeTypes_whenOnlyTypesProvided() throws {
        let flavour = TootSDKFlavour.sharkey
        let params = TootNotificationParams(types: [.mention]).corrected(for: flavour)
        #expect(
            params.excludeTypes == TootNotification.NotificationType.supported(by: flavour).subtracting([.mention]), "Incorrect exclude types for \(flavour)")
        #expect(params.types == nil, "Incorrect types for \(flavour)")
    }

    @Test func friendicaConvertTypesToExcludeTypes_whenBothTypesAndExcludedTypesProvided() throws {
        let flavour = TootSDKFlavour.friendica
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention]).corrected(for: flavour)
        #expect(params.excludeTypes == [.follow, .repost, .favourite, .poll], "Incorrect exclude types for \(flavour)")
        #expect(params.types == nil, "Incorrect types for \(flavour)")
    }

    @Test func sharkeyConvertTypesToExcludeTypes_whenBothTypesAndExcludedTypesProvided() throws {
        let flavour = TootSDKFlavour.sharkey
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention]).corrected(for: flavour)
        #expect(
            params.excludeTypes == TootNotification.NotificationType.supported(by: flavour).subtracting([.mention]), "Incorrect exclude types for \(flavour)")
        #expect(params.types == nil, "Incorrect types for \(flavour)")
    }

    @Test func friendicaConvertTypesToExcludeTypes_whenTypesOverlap() throws {
        let flavour = TootSDKFlavour.friendica
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention, .favourite]).corrected(for: flavour)
        #expect(params.excludeTypes == [.follow, .repost, .favourite, .poll], "Incorrect exclude types for \(flavour)")
        #expect(params.types == nil, "Incorrect types for \(flavour)")
    }

    @Test func sharkeyConvertTypesToExcludeTypes_whenTypesOverlap() throws {
        let flavour = TootSDKFlavour.sharkey
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention, .favourite]).corrected(for: flavour)
        #expect(
            params.excludeTypes == TootNotification.NotificationType.supported(by: flavour).subtracting([.mention]), "Incorrect exclude types for \(flavour)")
        #expect(params.types == nil, "Incorrect types for \(flavour)")
    }

    @Test func unmodifiedForOtherFlavours() throws {
        let flavours = Set(TootSDKFlavour.allCases).subtracting([.friendica, .sharkey])
        for flavour in flavours {
            let params = TootNotificationParams(types: [.mention]).corrected(for: flavour)
            #expect(params.excludeTypes == nil, "Incorrect exclude types for \(flavour)")
            #expect(params.types == [.mention], "Incorrect types for \(flavour)")
        }
    }

    @Test func friendicaQueryParams() throws {
        let flavour = TootSDKFlavour.friendica
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
        client.flavour = flavour

        let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
        let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
        #expect(
            query == [
                URLQueryItem(name: "exclude_types[]", value: "follow"),
                URLQueryItem(name: "exclude_types[]", value: "mention"),
                URLQueryItem(name: "exclude_types[]", value: "poll"),
                URLQueryItem(name: "exclude_types[]", value: "reblog"),
            ], "Incorrect params for \(flavour)")
    }

    @Test func sharkeyQueryParams() throws {
        let flavour = TootSDKFlavour.sharkey
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
        client.flavour = flavour

        let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
        let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
        #expect(
            query == [
                URLQueryItem(name: "exclude_types[]", value: "admin.report"),
                URLQueryItem(name: "exclude_types[]", value: "admin.sign_up"),
                URLQueryItem(name: "exclude_types[]", value: "emoji_reaction"),
                URLQueryItem(name: "exclude_types[]", value: "follow"),
                URLQueryItem(name: "exclude_types[]", value: "follow_request"),
                URLQueryItem(name: "exclude_types[]", value: "mention"),
                URLQueryItem(name: "exclude_types[]", value: "poll"),
                URLQueryItem(name: "exclude_types[]", value: "reblog"),
                URLQueryItem(name: "exclude_types[]", value: "severed_relationships"),
                URLQueryItem(name: "exclude_types[]", value: "status"),
                URLQueryItem(name: "exclude_types[]", value: "update"),
            ], "Incorrect params for \(flavour)")
    }

    @Test func pleromaAkkomaQueryParams() throws {
        for flavour in [TootSDKFlavour.pleroma, .akkoma] {
            let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
            client.flavour = flavour

            let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
            let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
            #expect(
                query == [
                    URLQueryItem(name: "exclude_types[]", value: "mention"),
                    URLQueryItem(name: "include_types[]", value: "favourite"),
                ], "Incorrect params for \(flavour)")
        }
    }

    @Test func mastodonQueryParams() throws {
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
        client.flavour = .mastodon

        let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
        let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
        #expect(
            query == [
                URLQueryItem(name: "exclude_types[]", value: "mention"),
                URLQueryItem(name: "types[]", value: "favourite"),
            ])
    }
}
