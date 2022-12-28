//
//  HTML.swift
//  Created by dave on 18/12/22.
//

import Foundation
import Down
import SwiftSoup

/// A wrapper for HTML content, returned from the instance API
/// This seeks to provide convenient NSAttributedString and plain text String versions of the HTML
public struct HTML: Codable {
    private var wrappedValue: String?
    
    /// The raw HTML
    public var raw: String? {
        return self.wrappedValue
    }
    
    /// A plain text string, generated from the HTML
    public var plainContent: String
    
    /// An attributedString generated from the raw HTML
    public var attributedString: NSAttributedString
    
    // MARK: - Initialization + decoding
    public init(value: String?, emojis: [Emoji]) {
        self.init(value: value, customEmojis: emojis)
    }
    
    public init(from decoder: Decoder) throws {
        // We decode only the wrapped value, and then generate our other properties basd on it
        let wrappedValue =  try decoder.singleValueContainer().decode(String.self)
        
        self.init(value: wrappedValue)
    }
    
    private init(value: String?, customEmojis: [Emoji] = []) {
        self.wrappedValue = value
        self.plainContent = HTML.stripHTMLFormatting(html: wrappedValue) ?? ""
        
        self.attributedString = HTML.attributedStringRenderer.createStringFrom(html: wrappedValue ?? "", emojis: customEmojis)
    }
    
    /// Remove all HTML tags, quick and dirty.
    /// - Parameter html: a string of html content
    /// - Returns: the processed string, free of HTML tags
    private static func stripHTMLFormatting(html: String?) -> String? {
        if let html = html,
           let doc: SwiftSoup.Document = try? SwiftSoup.parse(html) {
            return try? doc.text()
        } else {
            return nil
        }
    }
    
    /// The value we're initialized with
    public enum CodingKeys: CodingKey {
        case wrappedValue
    }
    
    /// Encodes  the wrapped value only when being encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }
    
    static internal var attributedStringRenderer: TootAttribStringRenderer = NullAttribStringRenderer()
}

extension HTML: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
    
    public static func == (lhs: HTML, rhs: HTML) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
