import Foundation
import XCTest

@testable import TootSDK

final class TootResponseTests: XCTestCase {

    // MARK: - Test Data

    private let sampleHeaders: [String: String] = [
        "Content-Type": "application/json",
        "X-RateLimit-Limit": "300",
        "X-RateLimit-Remaining": "299",
        "X-RateLimit-Reset": "1640995200",
        "Link":
            "<https://example.com/api/v1/accounts?limit=40&min_id=109>; rel=\"next\", <https://example.com/api/v1/accounts?limit=40&max_id=108>; rel=\"prev\"",
        "Cache-Control": "no-cache, no-store",
        "ETag": "\"abc123\"",
        "Last-Modified": "Wed, 21 Oct 2015 07:28:00 GMT",
        "Server": "Mastodon/4.0.0",
        "X-Request-Id": "req-12345",
        "X-Response-Time": "0.123s",
        "Mastodon-Version": "4.0.0",
        "X-Instance-Name": "example.com",
        "X-Software-Name": "mastodon",
        "X-Software-Version": "4.0.0",
        "Deprecation": "true",
        "Sunset": "Wed, 11 Nov 2020 23:59:59 GMT",
        "Content-Security-Policy": "default-src 'self'",
        "Strict-Transport-Security": "max-age=31536000",
        "X-Frame-Options": "DENY",
        "X-Content-Type-Options": "nosniff",
        "mastodon-async-refresh": "id=\"ImNvbnRleHQ6MTE1NDU4Mzk3NzM5NDE2MzQzOnJlZnJlc2gi--75a626571007cfb13bc09ef3f57bf062547c73dc\", retry=3",
    ]

    private let sampleData = ["test": "data"]
    private let sampleURL = URL(string: "https://example.com/api/v1/test")!
    private let sampleRawBody = Data("test response".utf8)

    // MARK: - Initialization Tests

    func testTootResponseInitialization() throws {
        // arrange & act
        let response = TootResponse(
            data: sampleData,
            headers: sampleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // assert
        XCTAssertEqual(response.data["test"], "data")
        XCTAssertEqual(response.headers.count, sampleHeaders.count)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.url, sampleURL)
        XCTAssertEqual(response.rawBody, sampleRawBody)
    }

    // MARK: - Rate Limiting Header Tests

    func testRateLimitHeadersWithInvalidValues() throws {
        // arrange
        let invalidHeaders = [
            "X-RateLimit-Limit": "invalid",
            "X-RateLimit-Remaining": "not-a-number",
            "X-RateLimit-Reset": "invalid-timestamp",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: invalidHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // act & assert
        XCTAssertNil(response.rateLimitLimit)
        XCTAssertNil(response.rateLimitRemaining)
        XCTAssertNil(response.rateLimitReset)
    }

    // MARK: - Cache Header Tests

    func testLastModifiedParsing() throws {
        // arrange
        let response = TootResponse(
            data: sampleData,
            headers: sampleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // act
        let lastModified = response.lastModified

        // assert
        XCTAssertNotNil(lastModified)

        // Use UTC calendar to avoid timezone issues
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: lastModified!)
        XCTAssertEqual(components.year, 2015)
        XCTAssertEqual(components.month, 10)
        XCTAssertEqual(components.day, 21)
        XCTAssertEqual(components.hour, 7)
        XCTAssertEqual(components.minute, 28)
    }

    // MARK: - Server Information Header Tests

    func testRequestIdFallback() throws {
        // arrange - test fallback from X-Request-Id to X-Request-ID
        let headersWithFallback = ["X-Request-ID": "fallback-id"]
        let response = TootResponse(
            data: sampleData,
            headers: headersWithFallback,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // act & assert
        XCTAssertEqual(response.requestId, "fallback-id")
    }

    // MARK: - Mastodon/Fediverse Specific Header Tests

    func testFediverseHeaders() throws {
        // arrange
        let response = TootResponse(
            data: sampleData,
            headers: sampleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // act & assert
        XCTAssertEqual(response.mastodonVersion, "4.0.0")
        XCTAssertEqual(response.instanceName, "example.com")
        XCTAssertEqual(response.softwareName, "mastodon")
        XCTAssertEqual(response.softwareVersion, "4.0.0")
        XCTAssertEqual(response.deprecationWarning, "true")
        XCTAssertEqual(response.sunsetWarning, "Wed, 11 Nov 2020 23:59:59 GMT")
        XCTAssertEqual(
            response.asyncRefresh,
            AsyncRefreshHint(id: "ImNvbnRleHQ6MTE1NDU4Mzk3NzM5NDE2MzQzOnJlZnJlc2gi--75a626571007cfb13bc09ef3f57bf062547c73dc", retry: 3)
        )
    }

    // MARK: - Security Header Tests

    func testSecurityHeaders() throws {
        // arrange
        let response = TootResponse(
            data: sampleData,
            headers: sampleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // act & assert
        XCTAssertEqual(response.requestId, "req-12345")
    }

    // MARK: - Status Code Convenience Tests

    func testStatusCodeConvenience() throws {
        // Test successful response
        let successResponse = TootResponse(
            data: sampleData,
            headers: [:],
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertTrue(successResponse.isSuccessful)
        XCTAssertFalse(successResponse.isRedirection)
        XCTAssertFalse(successResponse.isClientError)
        XCTAssertFalse(successResponse.isServerError)

        // Test redirection response
        let redirectResponse = TootResponse(
            data: sampleData,
            headers: [:],
            statusCode: 301,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertFalse(redirectResponse.isSuccessful)
        XCTAssertTrue(redirectResponse.isRedirection)
        XCTAssertFalse(redirectResponse.isClientError)
        XCTAssertFalse(redirectResponse.isServerError)

        // Test client error response
        let clientErrorResponse = TootResponse(
            data: sampleData,
            headers: [:],
            statusCode: 404,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertFalse(clientErrorResponse.isSuccessful)
        XCTAssertFalse(clientErrorResponse.isRedirection)
        XCTAssertTrue(clientErrorResponse.isClientError)
        XCTAssertFalse(clientErrorResponse.isServerError)

        // Test server error response
        let serverErrorResponse = TootResponse(
            data: sampleData,
            headers: [:],
            statusCode: 500,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertFalse(serverErrorResponse.isSuccessful)
        XCTAssertFalse(serverErrorResponse.isRedirection)
        XCTAssertFalse(serverErrorResponse.isClientError)
        XCTAssertTrue(serverErrorResponse.isServerError)
    }

    // MARK: - Convenience Method Tests

    func testCaseInsensitiveHeaderLookup() throws {
        // arrange
        let response = TootResponse(
            data: sampleData,
            headers: sampleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // act & assert
        XCTAssertEqual(response.header(named: "content-type"), "application/json")
        XCTAssertEqual(response.header(named: "CONTENT-TYPE"), "application/json")
        XCTAssertEqual(response.header(named: "Content-Type"), "application/json")
        XCTAssertNil(response.header(named: "non-existent-header"))
    }

    func testHeadersWithPrefix() throws {
        // arrange
        let response = TootResponse(
            data: sampleData,
            headers: sampleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // act
        let rateLimitHeaders = response.headers(withPrefix: "x-ratelimit")
        let xHeaders = response.headers(withPrefix: "x-")

        // assert
        XCTAssertEqual(rateLimitHeaders.count, 3)
        XCTAssertTrue(rateLimitHeaders.keys.contains("X-RateLimit-Limit"))
        XCTAssertTrue(rateLimitHeaders.keys.contains("X-RateLimit-Remaining"))
        XCTAssertTrue(rateLimitHeaders.keys.contains("X-RateLimit-Reset"))

        XCTAssertTrue(xHeaders.count >= 6)  // At least the X- headers we defined
        XCTAssertTrue(xHeaders.keys.contains("X-Request-Id"))
        XCTAssertTrue(xHeaders.keys.contains("X-Response-Time"))
    }

    // MARK: - Case-Insensitive Computed Property Tests

    func testRateLimitPropertiesWithLowercaseHeaders() throws {
        let lowercaseHeaders: [String: String] = [
            "x-ratelimit-limit": "300",
            "x-ratelimit-remaining": "299",
            "x-ratelimit-reset": "1640995200",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: lowercaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.rateLimitLimit, 300)
        XCTAssertEqual(response.rateLimitRemaining, 299)
        XCTAssertNotNil(response.rateLimitReset)
    }

    func testContentPropertiesWithMixedCaseHeaders() throws {
        let mixedCaseHeaders: [String: String] = [
            "content-type": "application/json",
            "CONTENT-LENGTH": "1234",
            "Content-Encoding": "gzip",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: mixedCaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.contentType, "application/json")
        XCTAssertEqual(response.contentLength, 1234)
        XCTAssertEqual(response.contentEncoding, "gzip")
    }

    func testCachePropertiesWithUppercaseHeaders() throws {
        let uppercaseHeaders: [String: String] = [
            "CACHE-CONTROL": "no-cache, no-store",
            "ETAG": "\"abc123\"",
            "LAST-MODIFIED": "Wed, 21 Oct 2015 07:28:00 GMT",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: uppercaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.cacheControl, "no-cache, no-store")
        XCTAssertEqual(response.etag, "\"abc123\"")
        XCTAssertNotNil(response.lastModified)
    }

    func testServerPropertiesWithLowercaseHeaders() throws {
        let lowercaseHeaders: [String: String] = [
            "server": "Mastodon/4.0.0",
            "x-request-id": "req-12345",
            "x-response-time": "0.123s",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: lowercaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.server, "Mastodon/4.0.0")
        XCTAssertEqual(response.requestId, "req-12345")
        XCTAssertEqual(response.responseTime, "0.123s")
    }

    func testFediversePropertiesWithLowercaseHeaders() throws {
        let lowercaseHeaders: [String: String] = [
            "mastodon-version": "4.0.0",
            "x-instance-name": "example.com",
            "x-software-name": "mastodon",
            "x-software-version": "4.0.0",
            "deprecation": "true",
            "sunset": "Wed, 11 Nov 2020 23:59:59 GMT",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: lowercaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.mastodonVersion, "4.0.0")
        XCTAssertEqual(response.instanceName, "example.com")
        XCTAssertEqual(response.softwareName, "mastodon")
        XCTAssertEqual(response.softwareVersion, "4.0.0")
        XCTAssertEqual(response.deprecationWarning, "true")
        XCTAssertEqual(response.sunsetWarning, "Wed, 11 Nov 2020 23:59:59 GMT")
    }

    func testSecurityPropertiesWithLowercaseHeaders() throws {
        let lowercaseHeaders: [String: String] = [
            "content-security-policy": "default-src 'self'",
            "strict-transport-security": "max-age=31536000",
            "x-frame-options": "DENY",
            "x-content-type-options": "nosniff",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: lowercaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.contentSecurityPolicy, "default-src 'self'")
        XCTAssertEqual(response.strictTransportSecurity, "max-age=31536000")
        XCTAssertEqual(response.xFrameOptions, "DENY")
        XCTAssertEqual(response.xContentTypeOptions, "nosniff")
    }

    func testPaginationWithLowercaseHeaders() throws {
        let lowercaseHeaders: [String: String] = [
            "link": "<https://example.com/api/v1/accounts?limit=40&min_id=109>; rel=\"next\""
        ]

        let response = TootResponse(
            data: sampleData,
            headers: lowercaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertNotNil(response.linkHeader)
        XCTAssertTrue(response.linkHeader!.contains("rel=\"next\""))
    }

    func testRequestIdFallbackWithLowercaseHeaders() throws {
        let lowercaseHeaders = ["x-request-id": "fallback-id"]
        let response = TootResponse(
            data: sampleData,
            headers: lowercaseHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.requestId, "fallback-id")
    }

    func testAllPropertiesWithRealWorldMastodonHeaders() throws {
        let mastodonStyleHeaders: [String: String] = [
            "content-type": "application/json; charset=utf-8",
            "x-ratelimit-limit": "300",
            "x-ratelimit-remaining": "299",
            "x-ratelimit-reset": "1640995200",
            "link": "<https://mastodon.social/api/v1/timelines/home?max_id=109>; rel=\"next\"",
            "cache-control": "no-cache, no-store",
            "server": "Mastodon",
            "x-request-id": "abc-123",
        ]

        let response = TootResponse(
            data: sampleData,
            headers: mastodonStyleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        XCTAssertEqual(response.contentType, "application/json; charset=utf-8")
        XCTAssertEqual(response.rateLimitLimit, 300)
        XCTAssertEqual(response.rateLimitRemaining, 299)
        XCTAssertNotNil(response.rateLimitReset)
        XCTAssertNotNil(response.linkHeader)
        XCTAssertEqual(response.cacheControl, "no-cache, no-store")
        XCTAssertEqual(response.server, "Mastodon")
        XCTAssertEqual(response.requestId, "abc-123")
    }

    // MARK: - Integration Tests

    func testTootResponseWithTypedData() throws {
        // arrange
        struct TestModel: Codable, Equatable {
            let id: String
            let name: String
        }

        let testModel = TestModel(id: "123", name: "Test")

        // act
        let response = TootResponse(
            data: testModel,
            headers: sampleHeaders,
            statusCode: 201,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // assert
        XCTAssertEqual(response.data, testModel)
        XCTAssertEqual(response.statusCode, 201)
        XCTAssertTrue(response.isSuccessful)
        XCTAssertEqual(response.rateLimitLimit, 300)
    }

    func testTootResponseWithArrayData() throws {
        // arrange
        let arrayData = ["item1", "item2", "item3"]

        // act
        let response = TootResponse(
            data: arrayData,
            headers: sampleHeaders,
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // assert
        XCTAssertEqual(response.data.count, 3)
        XCTAssertEqual(response.data[0], "item1")
        XCTAssertEqual(response.data[1], "item2")
        XCTAssertEqual(response.data[2], "item3")
    }

    func testTootResponseWithEmptyHeaders() throws {
        // arrange & act
        let response = TootResponse(
            data: sampleData,
            headers: [:],
            statusCode: 200,
            url: sampleURL,
            rawBody: sampleRawBody
        )

        // assert
        XCTAssertNil(response.rateLimitLimit)
        XCTAssertNil(response.rateLimitRemaining)
        XCTAssertNil(response.rateLimitReset)
        XCTAssertNil(response.linkHeader)
        XCTAssertNil(response.contentType)
        XCTAssertNil(response.mastodonVersion)
        XCTAssertTrue(response.isSuccessful)
    }
}
