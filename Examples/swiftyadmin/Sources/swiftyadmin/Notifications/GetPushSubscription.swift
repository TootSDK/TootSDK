//
//  GetPushSubscription.swift
//  
//
//  Created by Łukasz Rutkowski on 28/12/2023.
//

import Foundation
import ArgumentParser
import TootSDK

struct GetPushSubscription: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions

    func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }
        let subscription = try await client.getPushSubscription()
        print(subscription)
    }
}

