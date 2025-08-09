// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation
import Version

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - Initialization
public class TootClient: @unchecked Sendable {

    // MARK: - Public properties
    /// The URL of the instance we're connected to
    public var instanceURL: URL
    /// The application info retrieved from the instance
    public var currentApplicationInfo: TootApplication?
    /// Set this to `true` to see a `print()` of outgoing requests.
    public var debugRequests: Bool = false
    /// Set this to `true` to see a `print()` of request response.
    public var debugResponses: Bool = false
    /// Set this to `true` to see a `print()` for instance information.
    public var debugInstance: Bool = false
    /// The preferred fediverse server flavour to use for API calls
    public var flavour: TootSDKFlavour = .mastodon
    /// The parsed version of the instance we're connected to (used for feature detection)
    public var version: Version?
    /// The raw version string from the instance (for debugging/display purposes)
    public var versionString: String?
    /// The API versions supported by the instance (from InstanceV2 response)
    public var apiVersions: InstanceV2.APIVersions?
    /// The authorization scopes the client was initialized with
    public let scopes: [String]
    /// Data streams that the client can subscribe to
    public lazy var data = TootDataStream(client: self)
    /// WebSocket streaming API.
    public lazy var streaming = StreamingClient(client: self)

    /// The clientName the client was initialized with
    ///
    /// The clientName becomes the name of the app used during authentication and also becomes visible in the timeline when users post toots.
    /// Changing the value of clientName after authentication will result in your authentication token being invalidated.
    public let clientName: String

    /// The URL of the client's website.
    ///
    /// This URL is used as the hyperlink of the clientName in the details of a toot.
    public let clientWebsite: String?

    /// The User-Agent header string used in outgoing HTTP requests.
    ///
    /// Use this to identify the app, its version number, and its host operating system, for example.
    /// Changing this is optional, but recommended.
    ///
    /// https://developer.mozilla.org/en-US/docs/Glossary/User_agent
    public let httpUserAgent: String

    // MARK: - Internal properties
    internal var decoder: JSONDecoder = TootDecoder()
    internal var encoder: JSONEncoder = TootEncoder()
    internal var session: URLSession
    internal let validStatusCodes = 200..<300
    /// The current accessToken in use
    internal var accessToken: String?

    #if canImport(AuthenticationServices) && !os(tvOS) && !os(watchOS)
        internal lazy var defaultPresentationAnchor: TootPresentationAnchor = TootPresentationAnchor()
    #endif

    /// Initialize a new instance of `TootClient` by optionally providing an access token for authentication.
    ///
    /// After initializing, you need to manually call ``TootClient/connect()`` in order to obtain the correct flavour of the server.
    /// - Parameters:
    ///   - clientName: Name of the client to be used in outgoing HTTP requests. Defaults to `TootSDK`
    ///   - clientWebsite: A URL to the homepage of your client. Defaults to an empty string.
    ///   - session: the URLSession being used internally, defaults to shared
    ///   - instanceURL: the instance you are connecting to
    ///   - accessToken: the existing access token; if you already have one
    ///   - scopes: An array of authentication scopes, defaults to `"read", "write", "follow", "push"`
    public init(
        clientName: String = "TootSDK",
        clientWebsite: String? = nil,
        session: URLSession = URLSession.shared,
        instanceURL: URL,
        accessToken: String? = nil,
        scopes: [String] = ["read", "write", "follow", "push"],
        httpUserAgent: String? = nil
    ) {
        self.session = session
        self.instanceURL = instanceURL
        self.accessToken = accessToken
        self.scopes = scopes
        self.clientName = clientName
        self.clientWebsite = clientWebsite
        self.httpUserAgent = httpUserAgent ?? clientName
    }

    /// Initialize and connect a new instance of `TootClient`.
    ///
    /// The initializer calls ``TootClient/connect()`` internally in order to detect the server flavour.
    /// - Parameters:
    ///   - instanceURL: the instance you are connecting to
    ///   - clientName: Name of the client to be used in outgoing HTTP requests. Defaults to `TootSDK`
    ///   - clientWebsite: A URL to the homepage of your client. Defaults to an empty string.
    ///   - session: the URLSession being used internally, defaults to shared
    ///   - accessToken: the existing access token; if you already have one
    ///   - scopes: An array of authentication scopes, defaults to `"read", "write", "follow", "push"`
    public init(
        connect instanceURL: URL,
        clientName: String = "TootSDK",
        clientWebsite: String? = nil,
        session: URLSession = URLSession.shared,
        accessToken: String? = nil,
        scopes: [String] = ["read", "write", "follow", "push"],
        httpUserAgent: String? = nil
    ) async throws {
        self.session = session
        self.instanceURL = instanceURL
        self.accessToken = accessToken
        self.scopes = scopes
        self.clientName = clientName
        self.clientWebsite = clientWebsite
        self.httpUserAgent = httpUserAgent ?? clientName
        try await connect()
    }

    /// Prints extra debug details like outgoing requests and responses
    public func debugOn() {
        self.debugRequests = true
        self.debugResponses = true
        self.debugInstance = true
    }

    /// Stops printing debug details
    public func debugOff() {
        self.debugRequests = false
        self.debugResponses = false
        self.debugInstance = false
    }
}

// MARK: - Encoding/Decoding and fetching data
extension TootClient {

    internal func decode<T: Decodable>(_ decodable: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(decodable, from: data)
        } catch {
            let description = fetchError(T.self, data: data)

            if debugResponses {
                print(description)
            }

            throw TootSDKError.decodingError(description)
        }
    }

    /// Fetch data asynchronously and return the decoded `Decodable` object.
    internal func fetch<T: Decodable>(_ decode: T.Type, _ req: HTTPRequestBuilder) async throws -> T {
        let (data, _) = try await fetch(req: req)

        do {
            return try decoder.decode(decode, from: data)
        } catch {
            let description = fetchError(T.self, data: data)

            if debugResponses {
                print(description)
            }

            throw TootSDKError.decodingError(description)
        }
    }

    /// Fetch data asynchronously and return both the decoded object and HTTP response metadata.
    internal func fetchRaw<T: Decodable>(_ decode: T.Type, _ req: HTTPRequestBuilder) async throws -> TootResponse<T> {
        let (data, response) = try await fetch(req: req)

        let decodedData: T
        do {
            decodedData = try decoder.decode(decode, from: data)
        } catch {
            let description = fetchError(T.self, data: data)

            if debugResponses {
                print(description)
            }

            throw TootSDKError.decodingError(description)
        }

        // Convert HTTPURLResponse headers to [String: String]
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            if let keyString = key as? String, let valueString = value as? String {
                headers[keyString] = valueString
            }
        }

        return TootResponse(
            data: decodedData,
            headers: headers,
            statusCode: response.statusCode,
            url: response.url,
            rawBody: data
        )
    }

    private func fetchError<T: Decodable>(_ decode: T.Type, data: Data) -> String {
        var description: String = "Unknown decoding error"

        do {
            _ = try decoder.decode(decode, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            description = "context: \(context)"
        } catch let DecodingError.keyNotFound(key, context) {
            description = "Key '\(key)' not found:\(context.debugDescription)\n codingPath:\(context.codingPath)"
        } catch let DecodingError.valueNotFound(value, context) {
            description = "Value '\(value)' not found:\(context.debugDescription)\n codingPath:\(context.codingPath)"
        } catch let DecodingError.typeMismatch(type, context) {
            description = "Type '\(type)' mismatch:\(context.debugDescription)\n codingPath:\(context.codingPath)"
        } catch {
            description = error.localizedDescription
        }

        return description
    }

    /// Fetch data asynchronously and return the raw response.
    internal func fetch(req: HTTPRequestBuilder) async throws -> (Data, HTTPURLResponse) {
        if req.headers.index(forKey: "Content-Type") == nil {
            req.headers["Content-Type"] = "application/json"
        }

        if flavour == .sharkey && req.body == nil {
            req.headers["Content-Type"] = nil
            if req.method == .post || req.method == .put || req.method == .patch || req.method == .delete {
                req.headers["Content-Length"] = "0"
            }
        }

        if req.headers.index(forKey: "Accept") == nil {
            req.headers["Accept"] = "application/json"
        }

        if req.headers.index(forKey: "User-Agent") == nil {
            req.headers["User-Agent"] = httpUserAgent
        }

        if let accessToken = accessToken {
            req.headers["Authorization"] = "Bearer \(accessToken)"
        }

        let request = try req.build()
        return try await dataTask(request)
    }

    internal func dataTask(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        if debugRequests {
            print("➡️ flavour: \(self.flavour)")
            print("➡️ 🌏 \(request.httpMethod ?? "-") \(request.url?.absoluteString ?? "-")")
            for (k, v) in request.allHTTPHeaderFields ?? [:] {
                print("➡️ 🏷️ '\(k)': '\(v)'")
            }
            if let httpBody = request.httpBody {
                print("➡️ 💿", httpBody.prettyPrintedJSONString ?? String(data: httpBody, encoding: .utf8) ?? "Undecodable")
            }
        }
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TootSDKError.nonHTTPURLResponse(data: data, response: response)
        }

        if debugResponses {
            print("⬅️ 🌍 \(httpResponse.url?.absoluteString ?? "-")")
            print("⬅️ 🚦 HTTP \(httpResponse.statusCode)")
            for (k, v) in httpResponse.allHeaderFields {
                print("⬅️ 🏷️ '\(k)': '\(v)'")
            }
            print("⬅️ 💿", data.prettyPrintedJSONString ?? String(data: data, encoding: .utf8) ?? "Undecodable")
        }

        guard validStatusCodes.contains(httpResponse.statusCode) else {
            throw TootSDKError.invalidStatusCode(data: data, response: httpResponse)
        }

        return (data, httpResponse)
    }

    internal func requireFlavour(_ supportedFlavours: Set<TootSDKFlavour>) throws {
        if !supportedFlavours.contains(flavour) {
            throw TootSDKError.unsupportedFlavour(current: flavour, required: supportedFlavours)
        }
    }

    internal func requireFlavour(otherThan unsupportedFalvours: Set<TootSDKFlavour>) throws {
        let supportedFlavours = Set(TootSDKFlavour.allCases).subtracting(unsupportedFalvours)
        try requireFlavour(supportedFlavours)
    }

    internal func requireFeature(_ feature: TootFeature) throws {
        if !feature.isSupported(flavour: flavour, version: version, apiVersions: apiVersions) {
            throw TootSDKError.unsupportedFeature(feature: feature)
        }
    }

    /// Performs a request that returns paginated arrays
    /// - Parameters:
    ///   - req: the HTTP request to execute
    /// - Returns: the fetched paged array and page info
    internal func fetchPagedResult<T: Decodable>(_ req: HTTPRequestBuilder) async throws -> PagedResult<[T]> {
        let (data, response) = try await fetch(req: req)
        let decoded = try decode([T].self, from: data)
        var pagination: Pagination?

        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }

        // Pagination in TootSDK is opposite to pagination in Mastodon
        let nextPage = pagination?.prev
        let previousPage = pagination?.next
        let info = PagedInfo(maxId: previousPage?.maxId, minId: nextPage?.minId, sinceId: nextPage?.sinceId)

        return PagedResult(result: decoded, info: info, nextPage: nextPage, previousPage: previousPage)
    }

    /// Performs a request that returns paginated arrays and HTTP response metadata
    /// - Parameters:
    ///   - req: the HTTP request to execute
    /// - Returns: TootResponse containing the fetched paged array, page info, and HTTP metadata
    internal func fetchPagedResultRaw<T: Decodable>(_ req: HTTPRequestBuilder) async throws -> TootResponse<PagedResult<[T]>> {
        let (data, response) = try await fetch(req: req)
        let decoded = try decode([T].self, from: data)
        var pagination: Pagination?

        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }

        // Pagination in TootSDK is opposite to pagination in Mastodon
        let nextPage = pagination?.prev
        let previousPage = pagination?.next
        let info = PagedInfo(maxId: previousPage?.maxId, minId: nextPage?.minId, sinceId: nextPage?.sinceId)

        let pagedResult = PagedResult(result: decoded, info: info, nextPage: nextPage, previousPage: previousPage)

        // Convert HTTPURLResponse headers to [String: String]
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            if let keyString = key as? String, let valueString = value as? String {
                headers[keyString] = valueString
            }
        }

        return TootResponse(
            data: pagedResult,
            headers: headers,
            statusCode: response.statusCode,
            url: response.url,
            rawBody: data
        )
    }

}

extension TootClient: Equatable {
    public static func == (lhs: TootClient, rhs: TootClient) -> Bool {
        if lhs.instanceURL == rhs.instanceURL {
            return lhs.accessToken == rhs.accessToken
        } else {
            return false
        }
    }
}

extension TootClient {

    /// Provides the URL for authorizing with the current instanceURL
    /// - Returns: A URL which can be browsed to continue authorization
    public func createAuthorizeURL(callbackURI: String) async throws -> URL {
        return try await self.createAuthorizeURL(server: instanceURL, callbackURI: callbackURI)
    }

    /// Provides the URL for authorizing, with a custom server URL.
    /// - Returns: A URL which can be browsed to continue authorization
    public func createAuthorizeURL(server: URL, callbackURI: String) async throws -> URL {
        let authInfo = try await self.getAuthorizationInfo(callbackURI: callbackURI, scopes: self.scopes)
        currentApplicationInfo = authInfo.application
        return authInfo.url
    }

    /// Facility method to complete authentication by processing the response from the authorization step.
    /// Exchange the callback authorization code for an accessToken
    /// - Parameters:
    ///   - returnUrl: The full url including query parameters received by the service following the redirect after successfull authorizaiton
    ///   - callbackURI: The callback URI  (`redirect_uri`) which was used to initiate the authorization flow. Must match one of the redirect_uris declared during app registration.
    public func collectToken(returnUrl: URL, callbackURI: String) async throws -> String {

        guard
            let code = getCodeFrom(returnUrl: returnUrl),
            let clientId = currentApplicationInfo?.clientId,
            let clientSecret = currentApplicationInfo?.clientSecret
        else {
            throw TootSDKError.missingCodeOrClientSecrets
        }

        return try await collectToken(code: code, clientId: clientId, clientSecret: clientSecret, callbackURI: callbackURI)
    }

    private func getCodeFrom(returnUrl: URL) -> String? {
        var components = URLComponents()
        components.query = returnUrl.query
        return components.queryItems?.first(where: { $0.name == "code" })?.value
    }

    /// Exchange the callback authorization code for an accessToken.
    /// - Parameters:
    ///   - code: The authorization code returned by the server
    ///   - clientId: The client id of the application
    ///   - clientSecret: The client secret of the application
    ///   - callbackURI: The callback URL (`redirect_uri`) which was used to initiate the authorization flow.  Must match one of the redirect_uris declared during app registration.
    public func collectToken(code: String, clientId: String, clientSecret: String, callbackURI: String) async throws -> String {

        let info = try await getAccessToken(
            code: code, clientId: clientId,
            clientSecret: clientSecret,
            callbackURI: callbackURI,
            grantType: TootGrantType.login.rawValue,
            scopes: scopes)

        guard let accessToken = info.accessToken else {
            throw TootSDKError.clientAuthorizationFailed
        }

        self.accessToken = accessToken

        return accessToken
    }

    public func collectRegistrationToken(clientId: String, clientSecret: String, callbackURI: String) async throws -> String {

        let info = try await getAccessToken(
            code: nil, clientId: clientId,
            clientSecret: clientSecret,
            callbackURI: callbackURI,
            grantType: TootGrantType.register.rawValue,
            scopes: scopes)

        guard let accessToken = info.accessToken else {
            throw TootSDKError.clientAuthorizationFailed
        }

        self.accessToken = accessToken

        return accessToken
    }
}

extension TootClient {
    /// Uses the currently available credentials to connect to an instance and detect the most compatible server flavour.
    public func connect() async throws {
        if let nodeInfo = await getNodeInfoIfAvailable() {
            self.flavour = nodeInfo.flavour
            self.versionString = nodeInfo.software.version
            self.version = TootFeature.parseVersion(from: nodeInfo.software.version)
            if debugInstance {
                print("🎨 Detected fediverse instance flavour: \(nodeInfo.flavour), version: \(nodeInfo.software.version)")
            }
        } else {
            let instance = try await getInstanceInfo()
            self.flavour = instance.flavour
            self.versionString = instance.version
            self.version = TootFeature.parseVersion(from: instance.version)

            // Store API versions if this is an InstanceV2
            if let instanceV2 = instance as? InstanceV2 {
                self.apiVersions = instanceV2.apiVersions
                if debugInstance, let apiVersions = instanceV2.apiVersions {
                    print("🎨 Detected API versions - Mastodon: \(apiVersions.mastodon ?? 0)")
                }
            }

            if debugInstance {
                print("🎨 Detected fediverse instance flavour: \(instance.flavour), version: \(instance.version)")
            }
        }

        // Set the encoder userInfo after flavour has been determined
        encoder.userInfo[.tootSDKFlavour] = flavour
    }

    private func getNodeInfoIfAvailable() async -> NodeInfo? {
        return try? await getNodeInfo()
    }

    private func flavourFromNodeInfo() async -> TootSDKFlavour? {
        guard let nodeInfo = try? await getNodeInfo() else {
            return nil
        }
        if debugInstance {
            print("🎨 Detected fediverse instance flavour: \(nodeInfo.flavour), version: \(nodeInfo.software.version)")
        }
        return nodeInfo.flavour
    }

    private func flavourFromInstanceInfo() async throws -> TootSDKFlavour {
        let instance = try await getInstanceInfo()
        if debugInstance {
            print("🎨 Detected fediverse instance flavour: \(instance.flavour), version: \(instance.version)")
        }
        return instance.flavour
    }

    /// Returns `true` if this instance of `TootClient` has no `accessToken`.
    public var isAnonymous: Bool {
        accessToken == nil
    }

    /// Returns `true` if this instance of `TootClient` can perform methods that are related to given `feature`.
    ///
    /// - Parameter feature: The feature to check if is supported.
    /// - Returns: `true` if the feature is supported.
    public func supportsFeature(_ feature: TootFeature) -> Bool {
        return feature.isSupported(flavour: flavour, version: version, apiVersions: apiVersions)
    }
}
