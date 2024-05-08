//
//  TootNotificationParamsTests.swift
//
//
//  Created by Łukasz Rutkowski on 05/01/2024.
//

import XCTest

@testable import TootSDK

final class TootNotificationParamsTests: XCTestCase {

    private let flavoursNotSupportingTypes: [TootSDKFlavour] = [.friendica, .sharkey]

    func testFriendicaSharkeyKeepUnchanged_whenNothingSpecified() throws {
        for flavour in flavoursNotSupportingTypes {
            let params = TootNotificationParams().corrected(for: flavour)
            XCTAssertEqual(params.excludeTypes, nil, "Incorrect exclude types for \(flavour)")
            XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
        }
    }

    func testFriendicaSharkeyKeepUnchanged_whenOnlyExcludedTypesProvided() throws {
        for flavour in flavoursNotSupportingTypes {
            let params = TootNotificationParams(excludeTypes: [.mention]).corrected(for: flavour)
            XCTAssertEqual(params.excludeTypes, [.mention], "Incorrect exclude types for \(flavour)")
            XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
        }
    }

    func testFriendicaConvertTypesToExcludeTypes_whenOnlyTypesProvided() throws {
        let flavour = TootSDKFlavour.friendica
        let params = TootNotificationParams(types: [.mention]).corrected(for: flavour)
        XCTAssertEqual(params.excludeTypes, [.follow, .repost, .favourite, .poll], "Incorrect exclude types for \(flavour)")
        XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
    }

    func testSharkeyConvertTypesToExcludeTypes_whenOnlyTypesProvided() throws {
        let flavour = TootSDKFlavour.sharkey
        let params = TootNotificationParams(types: [.mention]).corrected(for: flavour)
        XCTAssertEqual(
            params.excludeTypes, Set(TootNotification.NotificationType.allCases).subtracting([.mention]), "Incorrect exclude types for \(flavour)")
        XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
    }

    func testFriendicaConvertTypesToExcludeTypes_whenBothTypesAndExcludedTypesProvided() throws {
        let flavour = TootSDKFlavour.friendica
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention]).corrected(for: flavour)
        XCTAssertEqual(params.excludeTypes, [.follow, .repost, .favourite, .poll], "Incorrect exclude types for \(flavour)")
        XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
    }

    func testSharkeyConvertTypesToExcludeTypes_whenBothTypesAndExcludedTypesProvided() throws {
        let flavour = TootSDKFlavour.sharkey
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention]).corrected(for: flavour)
        XCTAssertEqual(
            params.excludeTypes, Set(TootNotification.NotificationType.allCases).subtracting([.mention]), "Incorrect exclude types for \(flavour)")
        XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
    }

    func testFriendicaConvertTypesToExcludeTypes_whenTypesOverlap() throws {
        let flavour = TootSDKFlavour.friendica
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention, .favourite]).corrected(for: flavour)
        XCTAssertEqual(params.excludeTypes, [.follow, .repost, .favourite, .poll], "Incorrect exclude types for \(flavour)")
        XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
    }

    func testSharkeyConvertTypesToExcludeTypes_whenTypesOverlap() throws {
        let flavour = TootSDKFlavour.sharkey
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention, .favourite]).corrected(for: flavour)
        XCTAssertEqual(
            params.excludeTypes, Set(TootNotification.NotificationType.allCases).subtracting([.mention]), "Incorrect exclude types for \(flavour)")
        XCTAssertEqual(params.types, nil, "Incorrect types for \(flavour)")
    }

    func testUnmodifiedForOtherFlavours() throws {
        let flavours = Set(TootSDKFlavour.allCases).subtracting([.friendica, .sharkey])
        for flavour in flavours {
            let params = TootNotificationParams(types: [.mention]).corrected(for: flavour)
            XCTAssertEqual(params.excludeTypes, nil, "Incorrect exclude types for \(flavour)")
            XCTAssertEqual(params.types, [.mention], "Incorrect types for \(flavour)")
        }
    }

    func testFriendicaSharkeyQueryParams() throws {
        let flavour = TootSDKFlavour.friendica
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
        client.flavour = flavour

        let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
        let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
        XCTAssertEqual(
            query,
            [
                URLQueryItem(name: "exclude_types[]", value: "follow"),
                URLQueryItem(name: "exclude_types[]", value: "mention"),
                URLQueryItem(name: "exclude_types[]", value: "poll"),
                URLQueryItem(name: "exclude_types[]", value: "reblog"),
            ], "Incorrect params for \(flavour)")
    }

    func testFriendicaQueryParams() throws {
        let flavour = TootSDKFlavour.sharkey
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
        client.flavour = flavour

        let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
        let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
        XCTAssertEqual(
            query,
            [
                URLQueryItem(name: "exclude_types[]", value: "admin.report"),
                URLQueryItem(name: "exclude_types[]", value: "admin.sign_up"),
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

    func testPleromaAkkomaQueryParams() throws {
        for flavour in [TootSDKFlavour.pleroma, .akkoma] {
            let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
            client.flavour = flavour

            let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
            let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
            XCTAssertEqual(
                query,
                [
                    URLQueryItem(name: "exclude_types[]", value: "mention"),
                    URLQueryItem(name: "include_types[]", value: "favourite"),
                ], "Incorrect params for \(flavour)")
        }
    }

    func testMastodonQueryParams() throws {
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
        client.flavour = .mastodon

        let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
        let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
        XCTAssertEqual(
            query,
            [
                URLQueryItem(name: "exclude_types[]", value: "mention"),
                URLQueryItem(name: "types[]", value: "favourite"),
            ])
    }
}
