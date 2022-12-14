// Created by konstantin on 23/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation
import MultipartKit

internal struct HttpBody {
    internal var content: Data?
    internal var headers: [String: String]?
}

internal extension HttpBody {
    /// Initialize a new body with an object conform to `Encodable` which will converted to a JSON string.
    ///
    /// - Returns: HTTPBody
    static func json<T: Encodable>(_ object: T, encoder: JSONEncoder = .init()) throws -> HttpBody {
        let data = try encoder.encode(object)
        let headers = ["Content-Type": "application/json"]
        return HttpBody(content: data, headers: headers)
    }
    
    /// Initialize a new body for a multipart/form-data request with values from the provided encodable object
    ///
    /// - Returns: HTTPBody
    static func multipart<T: Encodable>(_ object: T, boundary: String) throws -> HttpBody {
        let encoded = try FormDataEncoder().encode(object, boundary: boundary)
        let data = Data(encoded.utf8)
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        return HttpBody(content: data, headers: headers)
    }
}
