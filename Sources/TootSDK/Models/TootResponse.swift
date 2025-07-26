// ABOUTME: TootResponse wrapper type that exposes HTTP response metadata alongside decoded data
// ABOUTME: Provides access to headers, status codes, URLs, and raw response bodies for debugging

import Foundation

/// A wrapper type that contains both the decoded response data and HTTP response metadata
///
/// This type allows access to HTTP headers, status codes, and other response metadata
/// alongside the decoded API response data. It's used by "Raw" methods to provide
/// complete access to the HTTP response while maintaining backward compatibility.
///
/// Example usage:
/// ```swift
/// let response = try await client.getListsRaw()
/// let lists = response.data
/// let rateLimit = response.rateLimitRemaining
/// let linkHeader = response.linkHeader
/// ```
public struct TootResponse<T> {
    /// The decoded response data (original return type)
    public let data: T

    /// HTTP response headers as key-value pairs
    public let headers: [String: String]

    /// HTTP status code
    public let statusCode: Int

    /// Response URL
    public let url: URL?

    /// Raw response body as Data (for debugging/fallback parsing)
    public let rawBody: Data

    /// Creates a new TootResponse with the provided data and metadata
    ///
    /// - Parameters:
    ///   - data: The decoded response data
    ///   - headers: HTTP response headers
    ///   - statusCode: HTTP status code
    ///   - url: Response URL
    ///   - rawBody: Raw response body
    public init(data: T, headers: [String: String], statusCode: Int, url: URL?, rawBody: Data) {
        self.data = data
        self.headers = headers
        self.statusCode = statusCode
        self.url = url
        self.rawBody = rawBody
    }
}

// MARK: - Rate Limiting Headers

extension TootResponse {
    /// Rate limit maximum requests per window (X-RateLimit-Limit)
    public var rateLimitLimit: Int? {
        headers["X-RateLimit-Limit"].flatMap(Int.init)
    }

    /// Rate limit remaining requests in current window (X-RateLimit-Remaining)
    public var rateLimitRemaining: Int? {
        headers["X-RateLimit-Remaining"].flatMap(Int.init)
    }

    /// Rate limit window reset time as Unix timestamp (X-RateLimit-Reset)
    public var rateLimitReset: Date? {
        headers["X-RateLimit-Reset"]
            .flatMap(TimeInterval.init)
            .map(Date.init(timeIntervalSince1970:))
    }
}

// MARK: - Pagination Headers

extension TootResponse {
    /// Link header for pagination navigation (Link)
    public var linkHeader: String? {
        headers["Link"]
    }
}

// MARK: - Content Headers

extension TootResponse {
    /// Response content type (Content-Type)
    public var contentType: String? {
        headers["Content-Type"]
    }

    /// Response content length (Content-Length)
    public var contentLength: Int? {
        headers["Content-Length"].flatMap(Int.init)
    }

    /// Response content encoding (Content-Encoding)
    public var contentEncoding: String? {
        headers["Content-Encoding"]
    }
}

// MARK: - Cache Headers

extension TootResponse {
    /// Cache control directive (Cache-Control)
    public var cacheControl: String? {
        headers["Cache-Control"]
    }

    /// Entity tag for caching (ETag)
    public var etag: String? {
        headers["ETag"]
    }

    /// Last modified timestamp (Last-Modified)
    public var lastModified: Date? {
        headers["Last-Modified"].flatMap { dateString in
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.date(from: dateString)
        }
    }
}

// MARK: - Server Information Headers

extension TootResponse {
    /// Server software information (Server)
    public var server: String? {
        headers["Server"]
    }

    /// Request ID for debugging (X-Request-Id, X-Request-ID)
    public var requestId: String? {
        headers["X-Request-Id"] ?? headers["X-Request-ID"]
    }

    /// Response time information (X-Response-Time)
    public var responseTime: String? {
        headers["X-Response-Time"]
    }
}

// MARK: - Mastodon/Fediverse Specific Headers

extension TootResponse {
    /// Mastodon version (Mastodon-Version)
    public var mastodonVersion: String? {
        headers["Mastodon-Version"]
    }

    /// Instance name (X-Instance-Name)
    public var instanceName: String? {
        headers["X-Instance-Name"]
    }

    /// Instance software type (X-Software-Name)
    public var softwareName: String? {
        headers["X-Software-Name"]
    }

    /// Instance software version (X-Software-Version)
    public var softwareVersion: String? {
        headers["X-Software-Version"]
    }

    /// Deprecated API endpoint warning (Deprecation)
    public var deprecationWarning: String? {
        headers["Deprecation"]
    }

    /// Sunset warning for API endpoint (Sunset)
    public var sunsetWarning: String? {
        headers["Sunset"]
    }
}

// MARK: - Security Headers

extension TootResponse {
    /// Content Security Policy (Content-Security-Policy)
    public var contentSecurityPolicy: String? {
        headers["Content-Security-Policy"]
    }

    /// Strict Transport Security (Strict-Transport-Security)
    public var strictTransportSecurity: String? {
        headers["Strict-Transport-Security"]
    }

    /// X-Frame-Options header (X-Frame-Options)
    public var xFrameOptions: String? {
        headers["X-Frame-Options"]
    }

    /// X-Content-Type-Options header (X-Content-Type-Options)
    public var xContentTypeOptions: String? {
        headers["X-Content-Type-Options"]
    }
}

// MARK: - Convenience Methods

extension TootResponse {
    /// Indicates if the response was successful (status code 2xx)
    public var isSuccessful: Bool {
        (200...299).contains(statusCode)
    }

    /// Indicates if the response was a redirection (status code 3xx)
    public var isRedirection: Bool {
        (300...399).contains(statusCode)
    }

    /// Indicates if the response was a client error (status code 4xx)
    public var isClientError: Bool {
        (400...499).contains(statusCode)
    }

    /// Indicates if the response was a server error (status code 5xx)
    public var isServerError: Bool {
        (500...599).contains(statusCode)
    }

    /// Get header value with case-insensitive lookup
    ///
    /// - Parameter name: Header name (case-insensitive)
    /// - Returns: Header value if found
    public func header(named name: String) -> String? {
        let lowercaseName = name.lowercased()
        for (key, value) in headers {
            if key.lowercased() == lowercaseName {
                return value
            }
        }
        return nil
    }

    /// Get all headers matching a prefix (case-insensitive)
    ///
    /// - Parameter prefix: Header name prefix (case-insensitive)
    /// - Returns: Dictionary of matching headers
    public func headers(withPrefix prefix: String) -> [String: String] {
        let lowercasePrefix = prefix.lowercased()
        var matchingHeaders: [String: String] = [:]

        for (key, value) in headers {
            if key.lowercased().hasPrefix(lowercasePrefix) {
                matchingHeaders[key] = value
            }
        }

        return matchingHeaders
    }
}
