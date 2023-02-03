<p align="center">
    <img src="https://user-images.githubusercontent.com/1049951/105351980-94fe4280-5bed-11eb-876e-ae60df0f41f0.png" height="64" alt="Multipart">
    <br>
    <br>
    <a href="https://docs.vapor.codes/4.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="https://discord.gg/vapor">
        <img src="https://img.shields.io/discord/431917998102675485.svg" alt="Team Chat">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://github.com/vapor/multipart-kit/actions">
        <img src="https://github.com/vapor/multipart-kit/workflows/test/badge.svg" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.2-brightgreen.svg" alt="Swift 5.2">
    </a>
    <a href="https://twitter.com/codevapor">
        <img src="https://img.shields.io/badge/twitter-codevapor-5AA9E7.svg" alt="Twitter">
    </a>
</p>

🏞 Multipart parser and serializer with `Codable` support for Multipart Form Data.

### Major Releases

The table below shows a list of MultipartKit major releases alongside their compatible NIO and Swift versions. 

|Version|NIO|Swift|SPM|
|---|---|---|---|
|4.0|2.2|5.2+|`from: "4.0.0"`|
|3.0|1.0|4.0+|`from: "3.0.0"`|
|2.0|N/A|3.1+|`from: "2.0.0"`|
|1.0|N/A|3.1+|`from: "1.0.0"`|

Use the SPM string to easily include the dependency in your `Package.swift` file.

```swift
.package(url: "https://github.com/vapor/multipart-kit.git", from: ...)
```

### Supported Platforms

MultipartKit supports the following platforms:

- Ubuntu 18.04+
- macOS 10.15+

## Overview

MultipartKit is a multipart parsing and serializing library. It provides `Codable` support for the special case of the `multipart/form-data` media type through a `FormDataEncoder` and `FormDataDecoder`. The parser delivers its output as it is parsed through callbacks suitable for streaming.

### Multipart Form Data

Let's define a `Codable` type and a choose a boundary used to separate the multipart parts.

```swift
struct User: Codable {
    let name: String
    let email: String
}
let user = User(name: "Ed", email: "ed@example.com")
let boundary = "abc123"
```

We can encode this instance of a our type using a `FormDataEncoder`.

```swift
let encoded = try FormDataEncoder().encode(foo, boundary: boundary)
```

The output looks then looks like this.
```
--abc123
Content-Disposition: form-data; name="name"

Ed
--abc123
Content-Disposition: form-data; name="email"

ed@example.com
--abc123--
```

In order to _decode_ this message we feed this output and the same boundary to a `FormDataDecoder` and we get back an identical instance to the one we started with.

```swift
let decoded = try FormDataDecoder().decode(User.self, from: encoded, boundary: boundary)
```

### A note on `null`
As there is no standard defined for how to represent `null` in Multipart (unlike, for instance, JSON), FormDataEncoder and FormDataDecoder do not support encoding or decoding `null` respectively. 

### Nesting and Collections

Nested structures can be represented by naming the parts such that they describe a path using square brackets to denote contained properties or elements in a collection. The following example shows what that looks like in practice.

```swift
struct Nested: Encodable {
    let tag: String
    let flag: Bool
    let nested: [Nested]
}
let boundary = "abc123"
let nested = Nested(tag: "a", flag: true, nested: [Nested(tag: "b", flag: false, nested: [])])
let encoded = try FormDataEncoder().encode(nested, boundary: boundary)
```

This results in the content below.

```
--abc123
Content-Disposition: form-data; name="tag"

a
--abc123
Content-Disposition: form-data; name="flag"

true
--abc123
Content-Disposition: form-data; name="nested[0][tag]"

b
--abc123
Content-Disposition: form-data; name="nested[0][flag]"

false
--abc123--
```

Note that the array elements always include the index (as opposed to just `[]`) in order to support complex nesting.
