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
        .package(path: "./multipart-kit-tootsdk"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.4.3"),
        .package(url: "https://github.com/karwa/swift-url.git", from: "0.4.1"),
       //  .package(url: "https://github.com/eneko/MarkdownGenerator", revision: "5575590ed9ea5cb02cd54a890cb43174efde7911")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TootSDK",
            dependencies: [.product(name: "MultipartKitTootSDK", package: "multipart-kit-tootsdk"),
                           .product(name:"SwiftSoup", package: "SwiftSoup"),
                           .product(name: "WebURL", package: "swift-url"),
                           .product(name: "WebURLFoundationExtras", package: "swift-url")]
                           // .product(name: "MarkdownGenerator", package: "MarkdownGenerator")
            ),
        .testTarget(
            name: "TootSDKTests",
            dependencies: ["TootSDK"],
            resources: [
                .copy("Resources/account.json"),
                .copy("Resources/account_moved.json"),
                .copy("Resources/activity.json"),
                .copy("Resources/post no emojis.json"),
                .copy("Resources/post with emojis and attachments.json"),
                .copy("Resources/post wordle linebreaks.json"),
            ]),
    ]
)
