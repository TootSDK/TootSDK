//
//  GetEndorsements.swift
//

import ArgumentParser
import Foundation
import TootSDK

struct GetEndorsements: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(name: .customShort("i"), help: "id of the user")
    var userID: String

    mutating func run() async throws {
        print("Getting featured accounts of user with local id: \(userID)")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        var pagedInfo: PagedInfo? = nil
        var hasMore = true

        while hasMore {
            let page = try await client.getEndorsements(forAccount: userID, pagedInfo)
            for endorsedAccount in page.result {
                print(endorsedAccount.acct)
            }
            hasMore = page.hasPrevious
            pagedInfo = page.previousPage
        }
    }
}

struct GetOwnAccountEndorsements: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    mutating func run() async throws {
        print("Getting featured accounts")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        var pagedInfo: PagedInfo? = nil
        var hasMore = true

        while hasMore {
            let page = try await client.getEndorsements(pagedInfo)
            for endorsedAccount in page.result {
                print("\(endorsedAccount.id) \(endorsedAccount.acct)")
            }
            hasMore = page.hasPrevious
            pagedInfo = page.previousPage
        }
    }
}
