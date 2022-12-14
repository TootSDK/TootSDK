# How you can Contribute

## Answer issues and contribute to discussions

Answering [issues](https://github.com/TootSDK/TootSDK/issues), participating in [discussions](https://github.com/TootSDK/TootSDK/discussions) is a great way to help, get familiar with the library, and shape its direction.

## Contribute to the TootSDK codebase

### Clone the `main` branch on your machine.

- Open the folder in Xcode (or your preferred editor with Swift support)

### Run tests

You can run tests using the Swift CLI by running `swift test` in the root of the project.

You can also execute tests in Xcode by switching to the Test navigator and executing one or more tests.

### Please respect the existing coding style

- Get familiar with the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Spaces, not tabs.
- Whitespace-only lines are not trimmed.
- We use SwiftLint to ensure a consistent look and feel of the library code. Your changes should contain no SwiftLink errors or warnings.
- SwiftLint is integrated as a package plugin. If you are using the command line, you can run `swift run swiftlint --fix`
- Avoid bringing in new libraries or dependencies without good justification. Any PR that brings in a new library needs to make the case for why it is necessary.

### Read our Architecture Decision Records (ADRs))

All major architectural decisions are captured in our [ADRs](https://github.com/TootSDK/TootSDK/architecture/decisions). It is worth reading these to gain context of our direction and general approach to the SDK, before writing code and submitting a PR.

### Please provide documentation for your changes

All methods and types which the library makes public ideally have a meaningful description and information on usage.

It is recommended to include unit tests covering your changes.

### Talk to the team 🤙

We'd love it if you'd talk to us over on the Fediverse! Current maintainers and admins for TootSDK are:

- [Konstantin](https://m.iamkonstantin.eu/konstantin)
- [David Gary Wood](https://social.davidgarywood.com/@davidgarywood)

### Open a pull request with your changes (targeting the `main` branch)!
