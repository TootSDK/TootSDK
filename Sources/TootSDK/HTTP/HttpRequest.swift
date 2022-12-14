// Created by konstantin on 23/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal protocol HttpRequest {
    /// The destination url of the rqeuest
    var url: URL? {get set}
    
    /// Method for submitting the request
    var method: HTTPMethod {get set}
    
    /// Headers to send with the request.
    var headers: [String: String] {get set}
    
    /// Add a new query parameter to the query string's value.
    ///
    /// - Parameters:
    ///   - name: name of the parameter to add.
    ///   - value: value of the parameter to add.
    func addQueryParameter(name: String, value: String)
    
    /// The body of ther request
    var body: HttpBody? {get set}
    
    /// Create an instance of `URLRequest` using the current configuration
    func build() throws -> URLRequest
}
