//
//  UpdateFilter.swift
//
//
//  Created by Łukasz Rutkowski on 02/07/2024.
//

import ArgumentParser
import Foundation
import TootSDK

struct UpdateFilter: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions
    @Option var id: String
    @Option var title: String?
    @Option var context: [Filter.Context] = []
    @Option var action: Filter.Action?
    @Option var expiresInSeconds: Int?
    @Option var deleteKeyword: [String] = []
    @Option var addKeyword: [String] = []
    @Option var renameKeywordId: [String] = []
    @Option var renameKeywordTitle: [String] = []

    func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }
        var keywords: [UpdateFilterParams.KeywordChange] = []
        for keywordIdToDelete in deleteKeyword {
            keywords.append(.delete(id: keywordIdToDelete))
        }
        for keyword in addKeyword {
            keywords.append(.create(keyword: keyword, wholeWord: false))
        }
        for (id, title) in zip(renameKeywordId, renameKeywordTitle) {
            keywords.append(.update(id: id, keyword: title))
        }

        let params = UpdateFilterParams(
            id: id,
            title: title,
            context: Set(context),
            action: action,
            expiry: expiresInSeconds.map { $0 > 0 ? .seconds($0) : .never },
            keywords: keywords
        )
        let updatedFilter = try await client.updateFilter(params)
        print(updatedFilter)
    }
}
