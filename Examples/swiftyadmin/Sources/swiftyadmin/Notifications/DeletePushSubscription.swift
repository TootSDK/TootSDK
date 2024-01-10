//
//  DeletePushSubscription.swift
//
//
//  Created by Łukasz Rutkowski on 29/12/2023.
//

import ArgumentParser
import Foundation
import TootSDK

struct DeletePushSubscription: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions

    func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }
        try await client.deletePushSubscription()
        print("SUCCESS")
    }
}
