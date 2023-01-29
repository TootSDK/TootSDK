// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum TootSDKError: Error, LocalizedError, Equatable {
    case decodingError(_ description: String)
    case missingCodeOrClientSecrets
    case nonHTTPURLResponse(data: Data, response: URLResponse)
    case invalidStatusCode(data: Data, response: HTTPURLResponse)
    case requiredURLNotSet
    case missingParameter(parameterName: String)
    case invalidParameter(parameterName: String)
    /// The requested operation is not supported by the current server flavour.
    case unsupportedFlavour(current: TootSDKFlavour, required: [TootSDKFlavour])
    case unexpectedError(_ description: String)
    /// The remote instance did not respond with the expected payload during authorization
    case clientAuthorizationFailed
    /// A "this should never happen" asssertion has failed
    case internalError(_ description: String)
    
    public var errorDescription: String? {
        switch self {
        case .decodingError(let description):
            return "[TootSDK bug] There was an error decoding incoming data:\n" + description + "."
        case .missingCodeOrClientSecrets:
            return "Unable to complete authorization: the client id, client secret and authorization code must be set."
        case .nonHTTPURLResponse:
            return "Unexpected response."
        case .invalidStatusCode(_, let response):
            return "Invalid HTTP status code: \(response.statusCode)."
        case .requiredURLNotSet:
            return "[TootSDK bug] HTTPRequestBuilder was used without setting a url."
        case .missingParameter(let parameterName):
            return "A required parameter is not provided: \(parameterName)."
        case .invalidParameter(let parameterName):
            return "A parameter has an illegal value: \(parameterName)."
        case .unsupportedFlavour(let current, let required):
            return "Operation not supported for server flavour \(current), compatible flavours are: \(required.map({"\($0)"}).joined(separator: ", "))."
        case .unexpectedError(let description):
            return "Unexpected error: \(description)"
        case .clientAuthorizationFailed:
            return "The remote instance did not respond with the expected payload during authorization."
        case .internalError(let description):
            return "[TootSDK bug] " + description + "."
        }
    }
}
