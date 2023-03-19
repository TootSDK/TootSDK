//
//  GetFeaturedTags.swift
//  Created by Łukasz Rutkowski on 18/03/2023.
//

import ArgumentParser
import Foundation
import TootSDK

struct GetFeaturedTags: AsyncParsableCommand {

    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Option(name: .customShort("i"), help: "id of the user")
    var userID: String

    mutating func run() async throws {
        print("Getting featured tags of user with local id: \(userID)")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)

        let featuredTags = try await client.getFeaturedTags(forUser: userID)
        print(featuredTags)
    }
}
