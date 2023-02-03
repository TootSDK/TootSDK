// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "multipart-kit-tootsdk",
    products: [
        .library(name: "MultipartKitTootSDK", targets: ["MultipartKitTootSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.2")
    ],
    targets: [
        .target(name: "MultipartKitTootSDK", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            .product(name: "Collections", package: "swift-collections")
        ]),
        .testTarget(name: "MultipartKitTests", dependencies: ["MultipartKitTootSDK"]),
    ]
)
