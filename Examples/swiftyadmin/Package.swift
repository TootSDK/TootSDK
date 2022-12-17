// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swiftyadmin",
  platforms: [
    .macOS(.v12)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.1.4"),  // version set to 1.2.0 as a work-around for version collision with SwiftLint from TootSDK which at this time only supports swift-argument-parser <=1.2.0
    .package(path: "../../"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .executableTarget(
      name: "swiftyadmin",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "TootSDK", package: "tootsdk"),
      ]),
    .testTarget(
      name: "swiftyadminTests",
      dependencies: ["swiftyadmin"]),
  ]
)
