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
        let followRequests = try await client.getPendingFollowRequests()
        print(followRequests)
    }
}
