# How you can Contribute

## Answer issues and contribute to discussions

Reviewing [issues](https://github.com/TootSDK/TootSDK/issues) and merged pull requests is a great way to help, get familiar with the library, and shape its direction.

## Contribute to the TootSDK codebase

### Clone the `main` branch on your machine.

- Open the folder in Xcode (or your preferred editor with Swift support)

### Run and add tests

You can run tests using the Swift CLI by running `swift test` in the root of the project.

You can also execute tests in Xcode by switching to the Test navigator and executing one or more tests.

Each addition to the codebase that introduces something new, or changes the way an existing piece of code works, should add or update relevant tests.

### Please respect the existing coding style

- Get familiar with the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Spaces, not tabs.
- Whitespace-only lines are not trimmed.
- We use [swift-format](https://github.com/apple/swift-format) to ensure a consistent look and feel of the library code. Your changes should contain no swift-format errors or warnings. Please lint code contributions before submitting e.g. `make lint`.
- Avoid bringing in new libraries or dependencies without good justification. Any PR that brings in a new library needs to make the case for why it is necessary.
- Structs that carry API parameters, or other associated information are created as separate objects (e.g. PollTranslation instead of Translation.Poll).
- We use the terminology of Post throughout TootSDK's code'. Mastodon calls it a Status, others might use the terminology of "Note", we decided early on as a project to standardise on "Post".
- Test data should be anonymized. For example: you can capture real data when testing and developing and then replace domains with `example.com` ([https://en.wikipedia.org/wiki/Example.com](https://en.wikipedia.org/wiki/Example.com)), users with "@testperson@example.com" and any Post data with [Lorem Ipsum](https://en.wikipedia.org/wiki/Lorem_ipsum)).
- Run `make lint` on your changes before opening a PR.

### Please provide documentation for your changes

All methods and types that the library makes public, should have a meaningful description and information on how to use.

It is recommended to include unit tests covering your changes.

Optionally, you may consider extending one of the examples in order to showcase the new functionality.

### Talk to the team 🤙

We'd love it if you'd talk to us over on the Fediverse! Current maintainers and admins for TootSDK are:

- [Konstantin](https://social.headbright.eu/@konstantin)
- [David Gary Wood](https://social.davidgarywood.com/@davidgarywood)

### Open a pull request with your changes (targeting the `main` branch)!
