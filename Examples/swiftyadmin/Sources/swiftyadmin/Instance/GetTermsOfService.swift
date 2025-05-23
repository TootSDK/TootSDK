import ArgumentParser
import Foundation
import TootSDK

struct GetInstanceTermsOfService: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "URL to the instance to connect to")
    var url: String

    @Option(name: .short, help: "Date (YYYY-MM-DD) of terms of service version to retrieve")
    var date: String?

    mutating func run() async throws {
        let client = TootClient(instanceURL: URL(string: url)!)
        try await client.connect()

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        let terms: TermsOfService
        if let dateString = date, let date = dateFormatter.date(from: dateString) {
            terms = try await client.getTermsOfService(effectiveAsOf: date)
        } else {
            terms = try await client.getTermsOfService()
        }
        print(terms)
    }
}
