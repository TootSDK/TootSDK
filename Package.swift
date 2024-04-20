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
        .library(name: "MultipartKitTootSDK",
                 targets: ["MultipartKitTootSDK"]),
        .library(name: "TootSDK",
                 targets: ["TootSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.2"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.4.3"),
        .package(url: "https://github.com/karwa/swift-url.git", from: "0.4.1"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MultipartKitTootSDK",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "Collections", package: "swift-collections")
            ]),
        .target(
            name: "TootSDK",
            dependencies: [
                "MultipartKitTootSDK",
                .product(name:"SwiftSoup", package: "SwiftSoup"),
                .product(name: "WebURL", package: "swift-url"),
                .product(name: "WebURLFoundationExtras", package: "swift-url"),
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "TootSDKTests",
            dependencies: ["TootSDK"],
            resources: [
                .copy("Resources/account.json"),
                .copy("Resources/account_verify_credentials_condensed.json"),
                .copy("Resources/account_mastodon_official.json"),
                .copy("Resources/account_moved.json"),
                .copy("Resources/account_pixelfed.json"),
                .copy("Resources/account_pixelfed_mutes_blocks.json"),
                .copy("Resources/activity.json"),
                .copy("Resources/familiar_followers_nofollowers.json"),
                .copy("Resources/featured_tag.json"),
                .copy("Resources/featured_tag_unused.json"),
                .copy("Resources/instance_akkoma.json"),
                .copy("Resources/instance_catodon_contact_removed.json"),
                .copy("Resources/instance_firefish_contact_removed.json"),
                .copy("Resources/instance_friendica_nocontact.json"),
                .copy("Resources/instance_iceshrimp_contact_removed.json"),
                .copy("Resources/instance_sharkey_contact_removed.json"),
                .copy("Resources/list.json"),
                .copy("Resources/post_edited.json"),
                .copy("Resources/post no emojis.json"),
                .copy("Resources/post with emojis and attachments.json"),
                .copy("Resources/post wordle linebreaks.json"),
                .copy("Resources/pixelfed.json"),
                .copy("Resources/mastodon.json"),
                .copy("Resources/pleroma.json"),
                .copy("Resources/relationship.json"),
                .copy("Resources/scheduled_post_sensitive.json"),
                .copy("Resources/scheduled_post_attachment.json"),
                .copy("Resources/scheduled_post_multiple_attachments.json"),
                .copy("Resources/scheduled_post_reply.json"),
                .copy("Resources/tag.json"),
                .copy("Resources/translation_attachment.json"),
                .copy("Resources/translation_poll.json"),
                .copy("Resources/encrypted_push_notification.base64"),
            ]),
    ]
)
