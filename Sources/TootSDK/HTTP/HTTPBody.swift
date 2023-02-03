// Created by konstantin on 23/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation
import MultipartKitTootSDK
import NIOCore

internal struct HTTPBody {
    internal var content: Data?
    internal var headers: [String: String]?
}

internal extension HTTPBody {
    /// Initialize a new body with an object conform to `Encodable` which will converted to a JSON string.
    ///
    /// - Returns: HTTPBody
    static func json<T: Encodable>(_ object: T, encoder: JSONEncoder = .init()) throws -> HTTPBody {
        let data = try encoder.encode(object)
        let headers = ["Content-Type": "application/json"]
        return HTTPBody(content: data, headers: headers)
    }
    
    /// Initialize a new body for a multipart/form-data request with values from the provided parts
    ///
    /// - Returns: HTTPBody
    static func multipart(_ parts: [MultipartPart], boundary: String) throws -> HTTPBody {
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        try MultipartSerializer().serialize(parts: parts, boundary: boundary, into: &buffer)
        let content = Data(buffer.readableBytesView)
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        return HTTPBody(content: content, headers: headers)
    }
    
    /// Initialize a new body for a multipart/form-data request with values from the provided encodable object
    ///
    /// - Returns: HTTPBody
    static func multipart<T: Encodable>(_ object: T, boundary: String) throws -> HTTPBody {
        let encoded = try FormDataEncoder().encode(object, boundary: boundary)
        let data = Data(encoded.utf8)
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        return HTTPBody(content: data, headers: headers)
    }
    
    /// Initialize a new body for a application/x-www-form-urlencoded request with values from the provided URLComponents
    ///
    /// - Returns: HTTPBody
    static func form(components: URLComponents) throws -> HTTPBody {
        let data = components.query?.data(using: .utf8)
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        return HTTPBody(content: data, headers: headers)
    }
    
    /// Initialize a new body for a application/x-www-form-urlencoded request with values from the provided query items
    ///
    /// - Returns: HTTPBody
    static func form(queryItems: [URLQueryItem]) throws -> HTTPBody {
        var components = URLComponents()
        components.queryItems = queryItems
        return try form(components: components)
    }
}
