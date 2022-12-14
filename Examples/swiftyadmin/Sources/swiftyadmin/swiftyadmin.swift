import ArgumentParser

@main
struct SwiftyAdmin: AsyncParsableCommand {
  static var configuration = CommandConfiguration(
    abstract:
      "An example command line utility to interact with and control a server using TootSDK.",
    version: "1.0.0",
    subcommands: [ListDomainBlocks.self, BlockDomain.self, UnblockDomain.self])
}
