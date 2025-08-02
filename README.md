<p><img src="https://raw.githubusercontent.com/TootSDK/TootSDK/main/media/logo.svg" width="100" /></p>

# TootSDK

<p><strong>Cross-platform Swift library for the Mastodon API</strong></p>

<p>
    <a href="https://developer.apple.com/swift/"><img alt="Swift 5.7" src="https://img.shields.io/badge/swift-5.7-orange.svg?style=flat"></a>
    <a href="https://developer.apple.com/swift/"><img alt="Platforms" src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blueviolet"></a>
     <a href="https://github.com/TootSDK/TootSDK/blob/main/LICENSE.md"><img alt="BSD 3-clause" src="https://img.shields.io/badge/License-BSD_3--Clause-blue.svg"></a>
    <a href="https://github.com/TootSDK/TootSDK/actions"><img alt="Build Status" src="https://github.com/TootSDK/TootSDK/actions/workflows/build.yml/badge.svg"></a>
</p>

TootSDK is a framework for Mastodon and the Fediverse, for iOS, macOS and other Swift platforms. It provides a toolkit for authorizing a user with an instance, and interacting with their posts.

TootSDK is a community developed SDK for Mastodon and the Fediverse.
It is designed to work with all major servers (Mastodon, Pleroma, PixelFed etc).

You can use TootSDK to build a client for Apple operating systems, or Linux with Vapor.

![overview of how TootSDK integrates with fedi platforms](https://raw.githubusercontent.com/TootSDK/TootSDK/main/media/overview.png)

## Why make TootSDK?

When app developers build apps for Mastodon and the Fediverse, every developer ends up having to solve the same set of problems when it comes to the API and data model.

[Konstantin](https://social.headbright.eu/@konstantin) and [Dave](https://social.lightbeamapps.com/@dave) decided to share this effort.

TootSDK is a shared Swift Package that any client app can be built on.

## Key Principles ⚙️

- Async/Await based. All asynchronous functions are defined as Async ones that you can use with Async/Await code (Note: full concurrency support is coming with Swift 6.2)
- Internal consistency and standardization of model property names
- Standardization across all supported Fediverse APIs
- Multi-server support with automatic flavour detection and version-aware feature handling
- Platform agnostic (TootSDK shouldn't care if it's on iOS, macOS or Linux!)

Please don't hesitate to open an issue or create a PR for features you need 🙏

## Quick start 🏁

It's easy to get started with TootSDK.

- Add TootSDK to your project via Swift Package Manager: `https://github.com/TootSDK/TootSDK`

- Instantiate with an instanceURL and accessToken:

```swift
  let instanceURL = URL(string: "social.yourinstance.com")
  let client = try await TootClient(connect: instanceURL, accessToken: "USERACCESSTOKEN")
```

The `connect` initializer automatically detects the server type (Mastodon, Pleroma, Pixelfed, etc.) and version, enabling TootSDK to adapt its behavior for optimal compatibility.

### Signing in (for macOS and iOS):

<details>
<summary>Network Sandbox Capability/Entitlement (macOS)</summary>

When using TootSDK within a macOS target you will need to enable the `com.apple.security.network.client` entitlement in your entitlements file or within the **Signing & Capabilities** tab in Xcode.

```
<key>com.apple.security.network.client</key>
<true/>
```

![Xcode target view showing the Signing & Capabilities tab with and arrow pointing to a checked Outgoing Connections (Client) option](media/network_sandbox_capability_entitlement.png)

</details>

- Instantiate your client without a token:

```swift
let client = try await TootClient(connect: url)
```

- Use the sign in helper we've created based on [`ASWebAuthenticationSession`](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession):

```swift
let client = try await TootClient(connect: url)

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
let client = try await TootClient(connect: instanceURL)
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

## Usage and key concepts

Once you have your client connected, you're going to want to use it. Our example apps and reference docs will help you get into the nitty gritty of it all, but some key concepts are highlighted here.

<details>
<summary>Accessing a user's timeline</summary>

There are several different types of timeline in TootSDK that you can access, for example their home timeline, the local timeline of their instance, or the federated timeline. These are all enumerated in the `Timeline` enum.

You can retrieve the latest posts (up to 40 on Mastodon) with a call like so:

```swift
let items = try await client.getTimeline(.home)
let posts = items.result
```

TootSDK returns Posts, Accounts, Lists and DomainBblocks as `PagedResult`. In our code, `items` is a PagedResult struct. It contains a property called `result` which will be the type of data request (in this case an array of `Post`).

</details>

<details>
<summary>Paging requests</summary>

Some requests in TootSDK allow pagination in order to request more information. TootSDK can request a specific page using the `PagedInfo` struct and handles paginaged server responses using the `PagedResult` struct.

PagedInfo has the following properties:

- maxId (Return results older than ID)
- minId (Return results immediately newer than ID)
- sinceId (Return results newer than ID)

So for example, if we want all posts from the user's home timeline that are newer than post ID 100, we could write:

```swift
let items = try await client.getTimeline(.home, PagedInfo(minId: 100))
let posts = items.result
```

Paged requests also deliver a PagedInfo struct as a property of the `PagedResult` returned, which means you can use that for subsequent requests of the same type.

```swift

var pagedInfo: PagedInfo?
var posts: [Post] = []

func retrievePosts() async {
    let items = try await client.getTimeline(.home, pagedInfo)
    posts.append(contentsOf: items.result)
    self.pagedInfo = items.pagedInfo
}

```

TootSDK implements several facilities to make it easier to iterate over multiple pages using the `hasPrevious`, `hasNext`, `previousPage` and `nextPage` properties of `PagedResult`:

```swift
var pagedInfo: PagedInfo? = nil
var hasMore = true
let query = TootNotificationParams(types: [.mention])

while hasMore {
  let page = try await client.getNotifications(params: query, pagedInfo)
  for notification in page.result {
    print(notification.id)
  }
  hasMore = page.hasPrevious
  pagedInfo = page.previousPage
}
```

⚠️ Different fediverse servers handle pagination differently and so there is no guarantee that `hasPrevious` or `hasNext` can correctly interpret the server response in all cases.

You can learn more about how pagination works for Fediverse servers using a Mastodon compatible API [here](https://docs.joinmastodon.org/api/guidelines/#pagination).

</details>

<details>
<summary>Streaming timelines</summary>

In TootSDK 4.0, experimental support for streaming timelines was introduced. It allows an app to subscribe for one or more available timelines in order to receive events as they happen instead of polling the server.

```swift
// open a socket to a specific timeline
let stream = try! await client.streaming.subscribe(to: .userNotification)

do {
    // listen for events
    for try await event in stream {
        print("got event")
        switch event {
        case .connectionUp:
            //...
        case .connectionDown:
            //...
        case .receivedEvent(let eventContent):
            //...
        }
    }
} catch {
    print(String(describing: error))
}
```

An example of subscribing to a timeline is available in [StreamEvents](Examples/swiftyadmin/Sources/swiftyadmin/Streams/StreamEvents.swift)

You can learn more about Streaminng event support for Mastodon [here](https://docs.joinmastodon.org/methods/streaming/).

You can learn more about Pleroma's implementation of streaming [here](https://api.pleroma.social/#operation/WebsocketHandler.streaming).

</details>

<details>
<summary>Creating an account</summary>

- Register the app with the following scopes `["read", "write:accounts"]`.

- Get instance information and determine the sign up requirements. Some instances may not be open for registration while others may require additional verification.

```swift
let instance = try await client.getInstanceInfo()
if instance.registrations == false {
  // instance not open for registration
  return
}
// ...
```

- Use the `registerAccount` method to create a user account:

```swift
let params = RegisterAccountParams(
      username: name, email: email, password: password, agreement: true, locale: "en")
let token = try await client.registerAccount(params: params)
```

</details>

## Server Flavours and Version Requirements 🌐

TootSDK supports multiple Fediverse server implementations and automatically adapts to their specific APIs and capabilities.

### Supported Server Types

TootSDK automatically detects and supports the following server types:

- **Mastodon** - The original and most widely used server
- **Pleroma** - Lightweight alternative implementation
- **Akkoma** - Fork of Pleroma with additional features
- **Pixelfed** - Instagram-like photo sharing platform
- **Friendica** - Facebook-like social platform
- **GoToSocial** - Lightweight ActivityPub server
- **Firefish** (formerly Calckey) - Feature-rich Misskey fork
- **Catodon** - Another Misskey variant
- **Iceshrimp** - Firefish fork focused on stability
- **Sharkey** - Misskey fork with additional features

### Automatic Detection

When you connect to a server, TootSDK automatically:

1. Detects the server type (flavour)
2. Parses the server version
3. Adapts API calls for optimal compatibility

```swift
let client = try await TootClient(connect: instanceURL)
print("Connected to \(client.flavour) server")
print("Version: \(client.versionString ?? "unknown")")
```

### Feature Detection

Not all features are available on all servers or server versions. TootSDK provides a robust feature detection system:

```swift
// Check if a feature is supported
if client.supportsFeature(.deleteMedia) {
    try await client.deleteMedia(id: mediaId)
} else {
    print("This server doesn't support deleting media")
}

// Features automatically check version requirements
// For example, deleteMedia requires Mastodon 4.4+
```

### Version Requirements

Some features require specific minimum versions. TootSDK handles this automatically:

```swift
// This will throw an error if the server doesn't support the feature
do {
    try await client.deleteMedia(id: mediaId)
} catch TootSDKError.unsupportedFeature {
    print("This feature requires Mastodon 4.4 or higher")
}
```

### Advanced Version Parsing

TootSDK handles various version string formats used by different servers:

- Standard semantic versions: `"4.2.0"`
- Pre-release versions: `"4.4.0-rc1"`
- Compatibility strings: `"2.7.2 (compatible; Pixelfed 0.11.4)"`
- Complex formats: `"3.5.3+glitch"`

The SDK extracts and parses version numbers if possible, or falling back to regex patterns when needed.

### Custom Feature Requirements

You can define custom features with specific server and version requirements:

```swift
// Feature only for specific servers
let customFeature = TootFeature(supportedFlavours: [.mastodon, .pleroma])

// Feature with version requirements for specific servers
let versionedFeature = TootFeature(requirements: [
    .from(.mastodon, version: "4.0.0"),  // Mastodon 4.0+
    .any(.pleroma)                       // Any Pleroma version
])

// Feature supported by ALL servers, but with version requirements for some
let universalFeature = TootFeature(allExcept: [
    .from(.mastodon, version: "3.0.0"),  // Mastodon needs 3.0+
    .from(.pleroma, version: "2.0.0")    // Pleroma needs 2.0+
    // All other servers support any version
])

// Feature supported by specific servers, with version requirements for some
let selectiveFeature = TootFeature(
    anyExcept: [.friendica, .akkoma],    // These support any version
    versionRequirements: [
        .from(.mastodon, version: "3.5.0"),  // Mastodon needs 3.5+
        .from(.pixelfed, version: "2.0.0")   // Pixelfed needs 2.0+
    ]
)

// Check if current server supports it
if client.supportsFeature(customFeature) {
    // Use the feature
}
```

</details>

## Further Documentation 📖

- Reference documentation is available [here](https://tootsdk.github.io/TootDocs/?v=2)
- Examples:
  - [swiftyadmin](https://github.com/TootSDK/TootSDK/tree/main/Examples/swiftyadmin) - a command line utility to interact with and control a server using TootSDK
  - [tootsdk-release](https://github.com/TootSDK/TootSDK/tree/main/Examples/tootsdk-release) - Example GitHub action to publish a post when a new release is published.

## Contributing

### Code of Conduct and Contributing rules 🧑‍⚖️

- Our guide to contributing is available here: [CONTRIBUTING.md](CONTRIBUTING.md).
- All contributions, pull requests, and issues are expected to adhere to our community code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License 📃

TootSDK is licensed with the BSD-3-Clause license, more information here: [LICENSE.MD](LICENSE.md)

This is a permissive license which allows for any type of use, provided the copyright notice is included.

## Acknowledgements 🙏

- The Mastodon API documentation https://github.com/mastodon/documentation
- We hat-tip top Metatext's source for some guidance on what's where: https://github.com/metabolist/metatext
- [Kris Slazinski](https://mastodon.social/@kslazinski) for our TootSDK logo 🤩

## Built with TootSDK

- [Fedicat](https://fedicat.com/)
- [Pipilo](https://apps.apple.com/pl/app/pipilo/id1584544719)
- [TootyGraph](https://github.com/samscam/tootygraph)
- [Topiary](https://lightbeamapps.com/topiary/)
- [TootLater](https://tootlater.kruschel.dev/)
- [Oxpecker](https://oxpecker.social)
- [Crystal](https://crystal.social)

## Related Works

- [TootSDK fork by technicat](https://codeberg.org/technicat/tootsdk)
