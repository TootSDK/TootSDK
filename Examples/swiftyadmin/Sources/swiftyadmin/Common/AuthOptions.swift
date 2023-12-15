//
//  AuthOptions.swift
//  
//
//  Created by Łukasz Rutkowski on 10/12/2023.
//

import Foundation
import ArgumentParser
import TootSDK

struct AuthOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "URL to the instance to connect to", transform: { urlString in
        guard let url = URL(string: urlString) else {
            throw ValidationError("Incorrect instance URL")
        }
        return url
    })
    var url: URL

    @Option(name: .shortAndLong, help: "Access token for an account with sufficient permissions.")
    var token: String

    @Flag(name: .shortAndLong)
    var verbose: Bool = false
}
