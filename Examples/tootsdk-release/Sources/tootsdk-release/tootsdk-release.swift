import ArgumentParser

@main
struct TootSDKRelease: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract:
            "An example command line utility make a release post when we create new releases of TootSDK",
        version: "1.0.0",
        subcommands: [
            MakePost.self
        ])
}
