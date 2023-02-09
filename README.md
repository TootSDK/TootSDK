<p><img src="./media/logo.svg" width="100" /></p>

# TootSDK

<p><strong>Cross-platform Swift library for the Mastodon API</strong></p>

<p>
    <a href="https://developer.apple.com/swift/"><img alt="Swift 5.7" src="https://img.shields.io/badge/swift-5.7-orange.svg?style=flat"></a>
    <a href="https://developer.apple.com/swift/"><img alt="Platforms" src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blueviolet"></a>
     <a href="https://github.com/TootSDK/TootSDK/blob/main/LICENSE.md"><img alt="BSD 3-clause" src="https://img.shields.io/badge/License-BSD_3--Clause-blue.svg"></a>
    <a href="https://github.com/TootSDK/TootSDK/actions"><img alt="Build Status" src="https://github.com/TootSDK/TootSDK/actions/workflows/build.yml/badge.svg"></a>
</p>

TootSDK is a framework for Mastodon and the Fediverse, for iOS. It provides a toolkit for authorizing a user with an instance, and interacting with their posts.

TootSDK is a community developed SDK for Mastodon and the Fediverse.
It is designed to work with all major servers (Mastodon, Pleroma, PixelFed etc).

You can use TootSDK to build a client for Apple operating systems, or Linux with Vapor.

![overview of how TootSDK integrates with fedi platforms](/media/overview.png)

## Why make TootSDK?

When app developers build apps for Mastodon and the Fediverse, every developer ends up having to solved the same set of problems when it comes to the API and data model.

[Konstantin](https://m.iamkonstantin.eu/konstantin) and [Dave](https://social.davidgarywood.com/@davidgarywood) decided to share this effort.
TootSDK is a shared Swift Package that any client app can be built on.

## Key Principles ⚙️

- Async/Await based. All asynchronous functions are defined as Async ones that you can use with Async/Await code
- Internal consistency and standardization of model property names
- Standardization across all supported Fediverse APIs
- Platform agnostic (TootSDK shouldn't care if it's on iOS, macOS or Linux!)

## Project Status 📈

- Mastodon - In progress
- Pleroma - In progress
- Pixelfed - To do
- Writefreely - To do

Our [roadmap](ROADMAP.md) shows where we want to take TootSDK. Our [project board](https://github.com/orgs/TootSDK/projects/1) shows our current backlog of work, and what is in flight.

Please don't hesitate to open an issue or create a PR for features you need 🙏

## Quick start 🏁

It's easy to get started with TootSDK.

- Add TootSDK to your project via Swift Package Manager: `https://github.com/TootSDK/TootSDK`

- Instantiate with an instanceURL and accessToken:

```
  let instanceURL = URL(string: "social.yourinstance.com")
  let client = TootClient(instanceURL: instanceURL, accessToken: "USERACCESSTOKEN")
```

### Signing in (for macOS and iOS):
- Instantiate your client without a token:

```swift
let client = TootClient(instanceURL: instanceURL)
```

- Use the sign in helper we've created based on [`ASWebAuthenticationSession`](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession):

```swift
let client = TootClient(instanceURL: url)

guard let accessToken = try await client.presentSignIn(callbackURI: callbackURI) else {
    // handle failed sign in
    return
}
```

That's it 🎉!


We recommend keeping the accessToken somewhere secure, for example the Keychain.

### Signing in (all platforms):

- Instantiate your client without a token:

```swift
let client = TootClient(instanceURL: instanceURL)
```

- Retrieve an authorization URL to present to the user (so they can sign in)

```swift
let authURL = client.createAuthorizeURL(callbackURI: "myapp://someurl")
```

- Present the the authorization URL as a web page
- Let the user sign in, and wait for the callbackURI to be called
- When that callbackURI is called, give it back to the client to collect the token

```swift
let accessToken = client.collectToken(returnUrl: url, callbackURI: callbackURI)
```

We recommend keeping the accessToken somewhere secure, for example the Keychain.

### Accessing a user's home feedfeed

```swift
let posts = try await client.data.stream(.timeLineHome)
```

## Further Documentation 📖

- Reference documentation is available [here](https://tootsdk.github.io/TootSDK/)
- Example apps:
  - [swiftui-toot](Examples/swiftui-toot/) - a SwiftUI app that shows authorization, a user's feed, posting and account operations
  - [swiftyadmin](Examples/swiftyadmin) - a command line utility to interact with and control a server using TootSDK
  - [vaportoot](Examples/vaportoot) - a web app in Vapor, that shows how to sign in and view a user's feed

## Contributing

### Code of Conduct and Contributing rules 🧑‍⚖️

- Our guide to contributing is available here: [CONTRIBUTING.md](CONTRIBUTING.md).
- All contributions, pull requests, and issues are expected to adhere to our community code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

### Key contributors ⚡️

- [Konstantin](https://m.iamkonstantin.eu/konstantin)
- [David Gary Wood](https://social.davidgarywood.com/@davidgarywood)

## License 📃

TootSDK is licensed with the BSD-3-Clause license, more information here: [LICENSE.MD](LICENSE.md)

This is a permissive license which allows for any type of use, provided the copyright notice is included.

## Acknowledgements 🙏

- The Mastodon API documentation https://github.com/mastodon/documentation
- We hat-tip top Metatext's source for some guidance on what's where: https://github.com/metabolist/metatext
- [Kris Slazinski](https://mastodon.social/@kslazinski) for our TootSDK logo 🤩
