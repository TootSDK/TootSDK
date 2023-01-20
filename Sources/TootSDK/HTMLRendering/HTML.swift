//
//  HTML.swift
//  Created by dave on 18/12/22.
//

import Foundation
import SwiftSoup

internal struct HTML {
    /// Remove all HTML tags, quick and dirty.
    /// - Parameter html: a string of html content
    /// - Returns: the processed string, free of HTML tags
    internal static func stripHTMLFormatting(html: String?) -> String? {
        if let html = html,
           let doc: SwiftSoup.Document = try? SwiftSoup.parse(html) {
            return try? doc.text()
        } else {
            return nil
        }
    }
}
