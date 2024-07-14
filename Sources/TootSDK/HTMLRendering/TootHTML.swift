//  TootHTML.swift
//  Created by dave on 18/12/22.

import Foundation
import SwiftSoup

///  Formatter for HTML content
public struct TootHTML {
    /// Remove all HTML tags, quick and dirty.
    /// - Parameter html: a string of html content
    /// - Returns: the processed string, free of HTML tags
    public static func extractAsPlainText(html: String?) -> String? {
        guard var html = html else { return nil }

        let linebreak = "|tootsdk-linebreak|"

        html = html.replacingOccurrences(of: "<p>", with: "")
        if html.hasSuffix("</p>") {
            html.removeLast("</p>".count)
        }
        html = html.replacingOccurrences(of: "</p>", with: linebreak)
        html = html.replacingOccurrences(of: "<br />", with: linebreak)
        html = html.replacingOccurrences(of: "<br>", with: linebreak)

        if let doc: SwiftSoup.Document = try? SwiftSoup.parse(html) {
            let removeHTML = try? doc.text()
            let withLineBreaksAddedBack = removeHTML?.replacingOccurrences(of: linebreak, with: "\n")
            return withLineBreaksAddedBack
        } else {
            return nil
        }
    }
}
