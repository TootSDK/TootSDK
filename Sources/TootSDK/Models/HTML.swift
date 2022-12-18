//
//  HTML.swift
//  
//
//  Created by dave on 18/12/22.
//

import Foundation

public struct HTML: Codable {
    private var wrappedValue: String?
    
    public var raw: String? {
        return self.wrappedValue
    }

    public var attributedString: NSAttributedString? {
        if let plain = wrappedValue?.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: ""),
           let data = plain.data(using: plain.fastestEncoding),
           let attributedString = try? NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil) {

            attributedString.removeAttribute(.font, range: NSRange(location: 0, length: attributedString.length))

            return attributedString
        } else {
            return nil
        }
    }

    public var plainContent: String? {
        guard let html = self.wrappedValue else { return nil }
                
        let htmlReplaceString: String = "<[^>]*>"
        
        if let regex = try? NSRegularExpression(pattern: htmlReplaceString, options: .caseInsensitive) {
            return regex.stringByReplacingMatches(in: html, options: [], range: NSRange(html.startIndex..., in: html), withTemplate: "")
        } else {
            return nil
        }
    }

    // MARK: - Initialization + decoding
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue =  try decoder.singleValueContainer().decode(String.self)
    }
    
    public enum CodingKeys: CodingKey {
        case wrappedValue
    }
    
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

