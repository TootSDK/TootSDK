// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TootSDK",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v7),
        .tvOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MultipartKitTootSDK",
            targets: ["MultipartKitTootSDK"]),
        .library(
            name: "TootSDK",
            targets: ["TootSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.2"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.7"),
        .package(url: "https://github.com/karwa/swift-url.git", from: "0.4.2"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
        .package(url: "https://github.com/mxcl/Version.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MultipartKitTootSDK",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "Collections", package: "swift-collections"),
            ]),
        .target(
            name: "TootSDK",
            dependencies: [
                "MultipartKitTootSDK",
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "WebURL", package: "swift-url"),
                .product(name: "WebURLFoundationExtras", package: "swift-url"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Version", package: "Version"),
            ],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "TootSDKTests",
            dependencies: ["TootSDK"]
        ),
    ]
)
