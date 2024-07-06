//
//  GetFilters.swift
//
//
//  Created by Łukasz Rutkowski on 02/07/2024.
//

import ArgumentParser
import Foundation
import TootSDK

struct GetFilters: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions

    func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }
        let filters = try await client.getFilters()
        print(filters)
    }
}
