// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TootSDK",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TootSDK",
            targets: ["TootSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TootSDK",
            dependencies: [.product(name: "MultipartKit", package: "multipart-kit")]
        ),
        .testTarget(
            name: "TootSDKTests",
            dependencies: ["TootSDK"],
            resources: [
                .copy("Resources/account.json"),
                .copy("Resources/account_moved.json"),
                .copy("Resources/activity.json")
            ]),
    ]
)
