import ArgumentParser
import Foundation
import TootSDK

struct ListDomainBlocks: AsyncParsableCommand {
    
    @Option(name: .short, help: "URL to the instance to connect to")
    var url: String
    
    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String
    
    mutating func run() async throws {
        print("Listing blocked domains:")
        let client = TootClient(instanceURL: URL(string: url)!, accessToken: token)
        
        
        if let results = try await client.adminGetDomainBlocks() {
            for domain in results {
                print(domain.id + ", " + domain.domain)
            }
        } else {
            print("No domains blocked")
        }
        
    }
}
