//
//  CreateFilter.swift
//  
//
//  Created by Łukasz Rutkowski on 02/07/2024.
//

import Foundation
import ArgumentParser
import TootSDK

struct CreateFilter: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions
    @Option var title: String
    @Option var context: [Filter.Context]
    @Option var action: Filter.Action?
    @Option var expiresInSeconds: Int?
    @Option var keywordTitle: [String] = []
    @Option var keywordWholeWord: [Bool] = []

    func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }
        let keywords = zip(keywordTitle, keywordWholeWord).map {
            CreateFilterParams.Keyword(keyword: $0, wholeWord: $1)
        }
        let params = CreateFilterParams(
            title: title,
            context: Set(context),
            action: action ?? .warn,
            expiresInSeconds: expiresInSeconds,
            keywords: keywords
        )
        let createdFilter = try await client.createFilter(params)
        print(createdFilter)
    }
}

extension Filter.Context: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument)
    }
}

extension Filter.Action: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument)
    }
}
