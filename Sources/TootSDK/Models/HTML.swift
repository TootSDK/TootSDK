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
    
    /// An attributedString generated from the raw HTML
    public var attributedString: NSAttributedString
    
    /// A plain text string, generated from the HTML
    public var plainContent: String
    
    // MARK: - Initialization + decoding
    public init(from decoder: Decoder) throws {
        // We decode only the wrapped value, and then generate our other properties basd on it
        self.wrappedValue =  try decoder.singleValueContainer().decode(String.self)
                
        self.attributedString = HTML.createAttributedString(value: wrappedValue) ?? NSAttributedString(string: "")
        self.plainContent = HTML.stripHTMLFormatting(html: wrappedValue) ?? ""
    }
    
    private static func createAttributedString(value: String?) -> NSAttributedString? {
        // swiftlint:disable todo
        // TODO: - make this load custom emojis, and check for other types of non-html payload (e.g markdown/bbcode)
        //       -  https://github.com/TootSDK/TootSDK/issues/35
        
        // Strip the paragraphs out, as otherwise we indent our text in the attributed string
        // We may want to add more to this, as payloads an vary.
        if let plain = value?.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: ""),
           let data = plain.data(using: plain.fastestEncoding),
           let value = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) {
            
            value.removeAttribute(.font, range: NSRange(location: 0, length: value.length))
            
            return value
        } else {
            return nil
        }
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
}

extension HTML: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
    
    public static func == (lhs: HTML, rhs: HTML) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
