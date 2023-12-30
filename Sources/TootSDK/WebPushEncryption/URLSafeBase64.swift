//
//  URLSafeBase64.swift
//  
//
//  Created by Łukasz Rutkowski on 30/12/2023.
//

import Foundation

extension Data {

    /// Initializes a `Data` from a Base-64 URL safe encoded String.
    ///
    /// - Parameter urlSafeBase64: The string to parse.
    /// - Returns: Decoded data or nil when the input is not recognized as valid Base-64.
    public init?(urlSafeBase64Encoded: String) {
        self.init(base64Encoded: urlSafeBase64Encoded.urlSafeBase64EncodedToBase64EncodedString())
    }
}

extension String {

    /// Converts Base-64 URL safe encoded String to Base-64 encoded String.
    ///
    /// - Parameter urlSafeBase64: The string to parse.
    /// - Returns: Base-64 encoded string.
    public func urlSafeBase64EncodedToBase64EncodedString() -> String {
        var base64 = replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let countMod4 = count % 4

        if countMod4 != 0 {
            base64.append(String(repeating: "=", count: 4 - countMod4))
        }

        return base64
    }
}
