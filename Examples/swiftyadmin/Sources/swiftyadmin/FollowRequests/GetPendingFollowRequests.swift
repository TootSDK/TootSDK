//
//  GetPendingFollowRequests.swift
//
//
//  Created by Łukasz Rutkowski on 10/12/2023.
//

import ArgumentParser
import Foundation
import TootSDK

struct GetPendingFollowRequests: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions

    mutating func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }

        var pagedInfo: PagedInfo? = nil
        var hasMore = true

        while hasMore {
            let page = try await client.getFollowRequests(pagedInfo)

            print("=== page ===")
            for follower in page.result {
                let json = String.init(data: try TootEncoder().encode(follower), encoding: .utf8)
                print(json ?? "")
            }
            hasMore = page.hasPrevious
            pagedInfo = page.previousPage
        }
    }
}
