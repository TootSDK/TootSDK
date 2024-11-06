//
//  ParsedContent.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 06/11/2024.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public struct ParsedContent {

    /// The unprocessed value received from the server.
    public var rawString: String

    /// A plain text string created by parsing value as HTML and stripping any formatting.
    public var plainString: String

    /// An attributed text string created by parsing value as HTML,
    public var attributedString: AttributedString

    public init(rawString: String, plainString: String, attributedString: AttributedString) {
        self.rawString = rawString
        self.plainString = plainString
        self.attributedString = attributedString
    }
}
