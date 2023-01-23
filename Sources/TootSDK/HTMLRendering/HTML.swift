//
//  HTML.swift
//  Created by dave on 18/12/22.
//

import Foundation
import SwiftSoup

public struct HTML {
    /// Remove all HTML tags, quick and dirty.
    /// - Parameter html: a string of html content
    /// - Returns: the processed string, free of HTML tags
    public static func stripHTMLFormatting(html: String?) -> String? {
        guard var html = html else { return nil }
        
        let linebreak = ":tootsdk-linebreak:"
        
        html = html.replacingOccurrences(of: "<p>", with: "")
        html = html.replacingOccurrences(of: "</p>", with: linebreak)
        html = html.replacingOccurrences(of: "<br />", with: linebreak)
        html = html.replacingOccurrences(of: "<br>", with: linebreak)
                   
        if let doc: SwiftSoup.Document = try? SwiftSoup.parse(html) {
            return try? doc.text().replacingOccurrences(of: linebreak, with: "\n")
        } else {
            return nil
        }
    }
}
