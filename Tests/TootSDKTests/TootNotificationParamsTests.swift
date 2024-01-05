//
//  TootNotificationParamsTests.swift
//
//
//  Created by Łukasz Rutkowski on 05/01/2024.
//

import XCTest
@testable import TootSDK

final class TootNotificationParamsTests: XCTestCase {

    func testFriendicaKeepUnchanged_whenNothingSpecified() throws {
        let params = TootNotificationParams().corrected(for: .friendica)
        XCTAssertEqual(params.excludeTypes, nil)
        XCTAssertEqual(params.types, nil)
    }

    func testFriendicaKeepUnchanged_whenOnlyExcludedTypesProvided() throws {
        let params = TootNotificationParams(excludeTypes: [.mention]).corrected(for: .friendica)
        XCTAssertEqual(params.excludeTypes, [.mention])
        XCTAssertEqual(params.types, nil)
    }

    func testFriendicaConvertTypesToExcludeTypes_whenOnlyTypesProvided() throws {
        let params = TootNotificationParams(types: [.mention]).corrected(for: .friendica)
        XCTAssertEqual(params.excludeTypes, [.follow, .repost, .favourite, .poll])
        XCTAssertEqual(params.types, nil)
    }

    func testFriendicaConvertTypesToExcludeTypes_whenBothTypesAndExcludedTypesProvided() throws {
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention]).corrected(for: .friendica)
        XCTAssertEqual(params.excludeTypes, [.follow, .repost, .favourite, .poll])
        XCTAssertEqual(params.types, nil)
    }

    func testFriendicaConvertTypesToExcludeTypes_whenTypesOverlap() throws {
        let params = TootNotificationParams(excludeTypes: [.favourite], types: [.mention, .favourite]).corrected(for: .friendica)
        XCTAssertEqual(params.excludeTypes, [.follow, .repost, .favourite, .poll])
        XCTAssertEqual(params.types, nil)
    }

    func testUnmodifiedForOtherFlavours() throws {
        let flavours = Set(TootSDKFlavour.allCases).subtracting([.friendica])
        for flavour in flavours {
            let params = TootNotificationParams(types: [.mention]).corrected(for: flavour)
            XCTAssertEqual(params.excludeTypes, nil)
            XCTAssertEqual(params.types, [.mention])
        }
    }

    func testFriendicaQueryParams() throws {
        let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
        client.flavour = .friendica

        let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
        let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
        XCTAssertEqual(query, [
            URLQueryItem(name: "exclude_types[]", value: "follow"),
            URLQueryItem(name: "exclude_types[]", value: "mention"),
            URLQueryItem(name: "exclude_types[]", value: "poll"),
            URLQueryItem(name: "exclude_types[]", value: "reblog"),
        ])
    }

    func testPleromaAkkomaQueryParams() throws {
        for flavour in [TootSDKFlavour.pleroma, .akkoma] {
            let client = TootClient(instanceURL: URL(string: "https://mastodon.social")!)
            client.flavour = flavour

            let params = TootNotificationParams(excludeTypes: [.mention], types: [.favourite])
            let query = client.createQuery(from: params).sorted { ($0.name, $0.value ?? "") < ($1.name, $1.value ?? "") }
            XCTAssertEqual(query, [
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
        XCTAssertEqual(query, [
            URLQueryItem(name: "exclude_types[]", value: "mention"),
            URLQueryItem(name: "types[]", value: "favourite"),
        ])
    }
}
