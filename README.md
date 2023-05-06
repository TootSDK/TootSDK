<p><img src="https://raw.githubusercontent.com/TootSDK/TootSDK/main/media/logo.svg" width="100" /></p>

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

![overview of how TootSDK integrates with fedi platforms](https://raw.githubusercontent.com/TootSDK/TootSDK/main/media/overview.png)

## Why make TootSDK?

When app developers build apps for Mastodon and the Fediverse, every developer ends up having to solve the same set of problems when it comes to the API and data model.

[Konstantin](https://m.iamkonstantin.eu/konstantin) and [Dave](https://social.davidgarywood.com/@davidgarywood) decided to share this effort.
TootSDK is a shared Swift Package that any client app can be built on.

## Key Principles ⚙️

- Async/Await based. All asynchronous functions are defined as Async ones that you can use with Async/Await code
- Internal consistency and standardization of model property names
- Standardization across all supported Fediverse APIs
- Platform agnostic (TootSDK shouldn't care if it's on iOS, macOS or Linux!)

## Project Status 📈

- Mastodon - Nearly there
- Pleroma - Nearly there
- Pixelfed - Nearly there
- Friendica - Nearly there 
- Akkoma - Nearly there
- Writefreely - To do

Our [roadmap](ROADMAP.md) shows where we want to take TootSDK. Our [project board](https://github.com/orgs/TootSDK/projects/1) shows our current backlog of work, and what is in flight.

Please don't hesitate to open an issue or create a PR for features you need 🙏

## Quick start 🏁

It's easy to get started with TootSDK.

- Add TootSDK to your project via Swift Package Manager: `https://github.com/TootSDK/TootSDK`

- Instantiate with an instanceURL and accessToken:

```swift
  let instanceURL = URL(string: "social.yourinstance.com")
  let client = try await TootClient(connect: instanceURL, accessToken: "USERACCESSTOKEN")
```

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


In TootSDK it is possible to subscribe to some types of content with AsyncSequences, a concept we've wrapped up in our `TootStream` object.

```swift
for posts in try await client.data.stream(.home) {
    print(posts)
}
```

Underneath the hood, this uses our Paging mechanism. This means that when you ask the client to refresh that stream, it will deliver you new results, from after the ones you requested.

```swift
client.data.refresh(.home)
```

You can also pass an initial PagedInfo value to the stream call. For example, to start steaming all posts from the user's home timeline that are newer than post ID 100:

```swift
for posts in try await client.data.stream(.home, PagedInfo(minId: 100) {
```

Some timelines require associated query parameters to configure. Luckily these are associated values that their timeline enumeration require when creating - so you can't miss them!

```swift

for posts in try await client.data.stream(HashtagTimelineQuery(tag: "iOSDev") {
    print(posts)
}
```

</details>

<details>
<summary>Creating an account</summary>

* Register the app with the following scopes `["read", "write:accounts"]`.

* Get instance information and determine the sign up requirements. Some instances may not be open for registration while others may require additional verification.

```swift
let instance = try await client.getInstanceInfo()
if instance.registrations == false {
  // instance not open for registration
  return
}
// ...
```

* Use the `registerAccount` method to create a user account:

```swift
let params = RegisterAccountParams(
      username: name, email: email, password: password, agreement: true, locale: "en")
let token = try await client.registerAccount(params: params)
```
</details>

## Further Documentation 📖

- Reference documentation is available [here](https://tootsdk.github.io/TootDocs/?v=2)
- Example apps:
  - [swiftui-toot](https://github.com/TootSDK/TootSDK/tree/main/Examples/swiftui-toot/) - a SwiftUI app that shows authorization, a user's feed, posting and account operations
  - [swiftyadmin](https://github.com/TootSDK/TootSDK/tree/main/Examples/swiftyadmin) - a command line utility to interact with and control a server using TootSDK
  - [vaportoot](https://github.com/TootSDK/TootSDK/tree/main/Examples/vaportoot) - a web app in Vapor, that shows how to sign in and view a user's feed

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
