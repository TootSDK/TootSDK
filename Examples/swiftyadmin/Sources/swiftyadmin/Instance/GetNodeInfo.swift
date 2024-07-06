//
//  GetNodeInfo.swift
//
//
//  Created by Łukasz Rutkowski on 06/07/2024.
//

import ArgumentParser
import Foundation
import TootSDK

struct GetNodeInfo: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "URL to the instance to connect to")
    var url: String

    mutating func run() async throws {
        let client = TootClient(instanceURL: URL(string: url)!)
        client.debugOn()
        let nodeInfo = try await client.getNodeInfo()
        print(nodeInfo)
        print(nodeInfo.flavour)
    }
}
