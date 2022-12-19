// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Initialization
public class TootClient {
    
    // MARK: - Public properties
    public var currentApplicationInfo: TootApplication?
    public var instanceURL: URL
    public var accessToken: String?
    /// Set this to `true` to see a `print()` of outgoing requests.
    public var debugRequests: Bool = false
    /// Set this to `true` to see a `print()` of request response.
    public var debugResponses: Bool = false
    /// The preferred fediverse server flavour to use for API calls
    public var flavour: TootSDKFlavour = .mastodon
    
    public let scopes: [String]
    
    public lazy var data = TootDataStream(client: self)
    
    // MARK: - Internal properties
    internal var decoder: JSONDecoder = TootDecoder()
    internal var encoder: JSONEncoder = TootEncoder()
    internal var session: URLSession
    internal let validStatusCodes = 200..<300
    
    /// Initialization
    /// - Parameters:
    ///   - session: the URLSession being used internally, defaults to shared
    ///   - instanceURL: the instance you are connecting to
    ///   - accessToken: the existing access token; if you already have one
    public init(session: URLSession = URLSession.shared,
                instanceURL: URL,
                accessToken: String? = nil,
                scopes: [String] = ["read", "write", "follow", "push"]) {
        self.session = session
        self.instanceURL = instanceURL
        self.accessToken = accessToken
        self.scopes = scopes
    }
    
    /// Prints extra debug details like outgoing requests and responses
    public func debugOn() {
        self.debugRequests = true
        self.debugResponses = true
    }
    
    /// Stops printing debug details
    public func debugOff() {
        self.debugRequests = false
        self.debugResponses = false
    }
}

// MARK: - Encoding/Decoding and fetching data
extension TootClient {
    
    internal func decode<T: Decodable>(_ decodable: T.Type, from data: Data) throws -> T {
       return try decoder.decode(decodable, from: data)
    }
    
    /// Fetch data asynchronously and return the decoded `Decodable` object.
    internal func fetch<T: Decodable>(_ decode: T.Type, _ req: HttpRequestBuilder) async throws -> T? {
        let (data, _) = try await fetch(req: req)
        
        if debugResponses {
            do {
                _ = try decoder.decode(decode, from: data)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
        
        return try decoder.decode(decode, from: data)
    }
    
    /// Fetch data asynchronously and return the raw response.
    internal func fetch(req: HttpRequestBuilder) async throws -> (Data, HTTPURLResponse) {
        if req.headers.index(forKey: "Content-Type") == nil {
            req.headers["Content-Type"] = "application/json"
        }
        
        if req.headers.index(forKey: "Accept") == nil {
            req.headers["Accept"] = "application/json"
        }
        
        if req.headers.index(forKey: "User-Agent") == nil {
            req.headers["User-Agent"] = "TootSDK"
        }
        
        if let accessToken = accessToken {
            req.headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        let request = try req.build()
        return try await dataTask(request)
    }
    
    internal func dataTask(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        if debugRequests {
            print("➡️ 🌏 \(request.url?.absoluteString ?? "-")")
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

    /// Provides the URL for authorizing
    public func createAuthorizeURL(server: URL, callbackUrl: String) async throws -> URL? {
        let authInfo = try await self.getAuthorizationInfo(callbackUrl: callbackUrl, scopes: self.scopes)
        currentApplicationInfo = authInfo?.application
        return authInfo?.url
    }

    /// Processes the response from the authorization step in exchange for an access token.
    /// Exchange the callback authorization code for an accessToken
    /// - Parameters:
    ///   - url: The full url including query parameters following the redirect after successfull authorizaiton
    ///   - callbackUrl: The callback URL  (`redirect_uri`) which was used to initiate the authorization flow. Must match one of the redirect_uris declared during app registration.
    public func collectToken(callbackUrl: URL) async throws -> String? {
        var components = URLComponents()
        components.query = callbackUrl.query
        
        guard
            let code = components.queryItems?.filter({ $0.name == "code" }).compactMap({ $0.value }).first,
            let clientId = currentApplicationInfo?.clientId,
            let clientSecret = currentApplicationInfo?.clientSecret
        else {
            throw TootSDKError.missingCodeOrClientSecrets
        }

        return try await collectToken(code: code, clientId: clientId, clientSecret: clientSecret, callbackUrl: callbackUrl.absoluteString)
    }
    
    /// Exchange the callback authorization code for an accessToken
    /// - Parameters:
    ///   - code: The authorization code returned by the server
    ///   - clientId: The client id of the application
    ///   - clientSecret: The client secret of the application
    ///   - callbackUrl: The callback URL (`redirect_uri`) which was used to initiate the authorization flow.  Must match one of the redirect_uris declared during app registration.
    public func collectToken(code: String, clientId: String, clientSecret: String, callbackUrl: String) async throws -> String? {
        
        let info = try await getAccessToken(code: code, clientId: clientId,
                                  clientSecret: clientSecret,
                                  callbackUrl: callbackUrl,
                                  scopes: scopes)
        
        accessToken = info?.accessToken
        return accessToken
    }

}
