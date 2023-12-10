//
//  GetPendingFollowRequests.swift
//  
//
//  Created by Łukasz Rutkowski on 10/12/2023.
//

import Foundation
import ArgumentParser
import TootSDK

struct GetPendingFollowRequests: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions

    mutating func run() async throws {
        let client = try await auth.connect()
        let followRequests = try await client.getPendingFollowRequests()
        print(followRequests)
    }
}
