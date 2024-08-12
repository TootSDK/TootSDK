import ArgumentParser
import Foundation
import TootSDK

struct StreamEvents: AsyncParsableCommand {
    @OptionGroup var auth: AuthOptions

    @Option(name: .short, help: "Stream name e.g. 'direct', 'public', etc.")
    var stream: String

    func run() async throws {
        let client = try await TootClient(connect: auth.url, accessToken: auth.token)
        if auth.verbose {
            client.debugOn()
        }

        guard let timeline = StreamingTimeline(rawValue: [stream]) else {
            print("Invalid stream name")
            return
        }
        let stream = try! await client.streaming.subscribe(to: timeline)

        print("Subscribed to \(stream), terminate the process to stop streaming.")

        do {
            for try await event in stream {
                switch event {
                case .connectionUp:
                    print("connection up")
                case .connectionDown:
                    print("connection down")
                case .receivedEvent(let eventContent):
                    print("received event: \(eventContent)")
                }
            }
        } catch {
            print(String(describing: error))
        }
    }
}
