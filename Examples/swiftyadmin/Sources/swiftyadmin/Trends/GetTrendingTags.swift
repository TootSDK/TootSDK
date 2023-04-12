import ArgumentParser
import Foundation
import TootSDK

struct GetTrendingTags: AsyncParsableCommand {
    
    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String
    
    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String
    
    @Option(name: .shortAndLong, help: "Maximum number of results to return")
    var limit: Int?
    
    @Option(name: .shortAndLong, help: "Skip the first n results")
    var offset: Int?
    
    mutating func run() async throws {
        print("Listing trending tags")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
        
        let results = try await client.getTrendingTags(limit: limit, offset: offset)
        for tag in results {
            print("\(tag.name) (\(tag.url))")
            if let history = tag.history {
                for day in history {
                    print("\t\(day)")
                }
            }
        }
    }
}
