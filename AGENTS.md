# CLAUDE.md

## Commands

### Building and Testing

- **Build**: `make build` or `swift build` (use `xcrun swift build` to avoid toolchain conflicts)
- **Test**: `make test` or `swift test`
- **Auto-format**: `make lint` - applies formatting and fixes lint issues across Sources, Tests, and Examples
- **Clean**: `make clean` or `swift package clean`

### Single Test Execution

Run individual test files using:

```bash
swift test --filter TestClassName
swift test --filter TestClassName.testMethodName
# Example: swift test --filter FlavourTests.testDetectsMastodon4
```

### Testing with Fixtures

Tests use JSON fixtures from real server responses located in `Tests/TootSDKTests/Resources/`. Use the helper function `localObject<T>(_ type: T.Type, _ filename: String)` to load fixtures in tests.

## Architecture

### Core Structure

TootSDK is a Swift Package Manager library that provides a unified SDK for interacting with Mastodon-compatible Fediverse servers. The architecture follows these key patterns:

**TootClient** (`Sources/TootSDK/TootClient/TootClient.swift`) - Main entry point and HTTP client

- Handles authentication, server communication, and API calls
- Contains flavour detection for different server types (Mastodon, Pleroma, Pixelfed, etc.)
- Manages access tokens and session state
- Provides both async/await and traditional completion handler APIs

**Multi-server Support** (`Sources/TootSDK/Models/TootSDKFlavour.swift`)

- Supports 10+ Fediverse server implementations (Mastodon, Pleroma, Pixelfed, Friendica, Akkoma, Firefish, Catodon, Iceshrimp, Sharkey, GoToSocial)
- Automatic server flavour detection to handle API differences
- Unified data models that work across server types

**Data Models** (`Sources/TootSDK/Models/`)

- Rich set of models for Posts, Accounts, Timelines, Notifications, etc.
- Consistent naming (uses "Post" terminology instead of Mastodon's "Status")
- Handles pagination with `PagedResult<T>` and `PagedInfo` structures
- Support for server-specific features through optional properties

**Client Extensions** (`Sources/TootSDK/TootClient/TootClient+*.swift`)

- Functionality is split across 20+ extensions by feature area:
  - `TootClient+Account.swift` - Account management, profiles, relationships
  - `TootClient+Post.swift` - Creating, editing, boosting posts
  - `TootClient+TimeLine.swift` - Home, local, federated timelines
  - `TootClient+Notifications.swift` - Push notifications, mentions
  - `TootClient+Streaming.swift` - WebSocket streaming API
  - `TootClient+Media.swift` - Media upload and processing
- Each extension focuses on a specific API domain

**Streaming Support** (`Sources/TootSDK/TootClient/Streaming/`)

- WebSocket-based real-time streaming for timelines and notifications
- Actor-based `StreamingClient` for connection lifecycle management
- Async sequence support for event processing
- Automatic retry with exponential backoff
- Multiple subscribers per timeline with automatic cleanup

**HTML Rendering** (`Sources/TootSDK/HTMLRendering/`)

- Cross-platform HTML to AttributedString conversion
- Platform-specific renderers for AppKit, UIKit, and universal contexts
- Handles Mastodon's HTML content formatting

### Platform Support

- **Platforms**: iOS 14+, macOS 12+, watchOS 7+, tvOS 14+, Linux
- **Authentication**: ASWebAuthenticationSession on Apple platforms, manual OAuth flow on others
- **Networking**: Foundation URLSession with async/await support

### Testing Strategy

- Comprehensive unit tests with JSON fixtures for different server responses
- Test data anonymized (example.com domains, Lorem Ipsum content)
- Server-specific test cases for API variations
- Resource files in `Tests/TootSDKTests/Resources/` for realistic server responses

## Code Style and Conventions

### Swift Format Configuration

- Uses swift-format with custom `.swift-format` configuration
- 4-space indentation, 150 character line length
- File-scoped declaration privacy preferred
- Specific formatting rules defined in `.swift-format`

### Naming Conventions

- Use "Post" terminology throughout (not "Status" or "Note")
- Parameter structs as separate objects (e.g., `RegisterAccountParams`)
- Consistent async/await method naming
- Flavour-agnostic naming in public APIs

### API Design Patterns

- Async/await first, with @Sendable conformance where needed
- PagedResult<T> for paginated responses with built-in navigation
- Optional parameters via dedicated parameter structs
- Comprehensive error handling with TootSDKError types
- Raw method pattern: Each API method should have a corresponding `*Raw()` variant that returns `TootResponse<T>` containing the decoded data along with HTTP metadata (headers, status code, URL, raw body). The standard method calls the Raw method and returns just the data for backward compatibility. See PR #360 for details.

### Development Guidelines

- Avoid new dependencies without strong justification
- Test data must be anonymized before inclusion (example.com domains, Lorem Ipsum content)
- All public methods require documentation
- Maintain cross-platform compatibility (no UIKit/AppKit specific code in core)
- Follow Swift API Design Guidelines
- Use conventional commit messages for version control
