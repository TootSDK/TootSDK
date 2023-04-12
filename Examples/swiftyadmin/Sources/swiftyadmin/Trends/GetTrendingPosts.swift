import ArgumentParser
import Foundation
import TootSDK

struct GetTrendingPosts: AsyncParsableCommand {
    
    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String
    
    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String
    
    @Option(name: .shortAndLong, help: "Maximum number of results to return")
    var limit: Int?
    
    @Option(name: .shortAndLong, help: "Skip the first n results")
    var offset: Int?
    
    mutating func run() async throws {
        print("Listing trending posts")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
        
        let results = try await client.getTrendingPosts(limit: limit, offset: offset)
        for post in results {
            let json = String.init(data: try TootEncoder().encode(post), encoding: .utf8)
            print(json ?? "")
        }
    }
}
