<p><img src="./media/tootsdk_logo.png" width="100" /></p>

# TootSDK 

<p><strong>Cross-platform Swift library for the Mastodon API</strong></p>

<p>
    <a href="https://developer.apple.com/swift/"><img alt="Swift 5.7" src="https://img.shields.io/badge/swift-5.7-orange.svg?style=flat"></a>
    <a href="https://developer.apple.com/swift/"><img alt="Platforms" src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blueviolet"></a>
    <a href="https://github.com/kkostov/TootSDK/blob/master/LICENSE.md"><img alt="License" src="https://img.shields.io/github/license/kkostov/TootSDK.svg?maxAge=2592000"></a>
    <a href="https://github.com/kkostov/TootSDK/actions"><img alt="Build Status" src="https://github.com/kkostov/TootSDK/actions/workflows/build.yml/badge.svg"></a>
</p>

## What is this? 🙋‍♂️

TootSDK is a framework for Mastodon and the Fediverse, for iOS. It provides a toolkit for authorizing a user with an instance, and interacting with their posts.

TootSDK is a community developed SDK for Mastodon and the Fediverse.
It is designed to work with all major servers (Mastodon, Pleroma, PixelFed etc).

You can use TootSDK to build a client for Apple operating systems, or on linux via Vapor.

## Getting started 🏁

You can add TootSDK to your project via Swift Package Manager:
`https://github.com/kkostov/TootSDK`

Check out our example iOS project `TootSDK-iOS-Demo` in the Examples directory. This provides an example application using SwiftUI and TootSDK to browse a feed and create posts.

## Key contributors ⚡️

- [Konstantin](https://m.iamkonstantin.eu/konstantin)
- [David Gary Wood](https://social.davidgarywood.com/@davidgarywood)

## Code of Conduct and Contributing rules 🧑‍⚖️

- Our guide to contributing is available here: [CONTRIBUTING.md](CONTRIBUTING.md).
- All contributions, pull requests, and issues are expected to adhere to our community code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License 📃

TootSDK is licensed with the BSD-3-Clause license, more information here: [LICENSE.MD](LICENSE.md)

This is a permissive license which allows for any type of use, provided the copyright notice is included.

## Acknowledgements 🙏

- The Mastodon API documentation https://github.com/mastodon/documentation
- We hat-tip top Metatext's source for some guidance on what's where: https://github.com/metabolist/metatext

## Examples

We have prepared several examples that demonstrate how to use TootSDK in your projects.
They are all located in the `Examples` folder of the repository.

### Using TootSDK with SwiftUI

The SwiftUI-Toot app showcases usage of the framework in a SwiftUI app.

### Using TootSDK with Vapor

`$ cd ./Examples/vaportoot`
`vapor run`

- Navigate to `localhost:8080` in your browser and fill in the url of a fedi server to connect with.

- We've added examples for making a post, viewing the timeline and interacting with posts (like reply and repost).
