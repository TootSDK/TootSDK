// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum TootSDKError: Error, LocalizedError, Equatable {
    case decodingError
    case authorizationError
    case missingCodeOrClientSecrets
    case nonHTTPURLResponse(data: Data, response: URLResponse)
    case invalidStatusCode(data: Data, response: HTTPURLResponse)
    case requiredUrlNotSet
    case missingParameter(parameterName: String)
    case invalidParameter(parameterName: String)
    
    public var errorDescription: String? {
        switch self {
        case .authorizationError:
            return "Authorization error"
        case .decodingError:
            return "error decoding data"
        case .missingCodeOrClientSecrets:
            return "missing code or client data"
        case .nonHTTPURLResponse:
            return "non http url"
        case .invalidStatusCode(_, let response):
            return "invalid status code: \(response.statusCode)"
        case .requiredUrlNotSet:
            return "required URL not set"
        case .missingParameter(let parameterName):
            return "missing parameter: \(parameterName)"
        case .invalidParameter(let parameterName):
            return "invalid parameter: \(parameterName)"
        }
    }
}
