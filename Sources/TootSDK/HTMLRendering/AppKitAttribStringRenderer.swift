//  AppKitAttribStringRenderer.swift
//  Created by dave on 28/12/22.

#if canImport(AppKit)
import Foundation
import AppKit
import WebURL
import WebURLFoundationExtras
import SwiftSoup

public class AppKitAttribStringRenderer: TootAttribStringRenderer {
        
    /// Renders the HTML to an NSAttributedString
    /// - Parameters:
    ///   - html: html description
    ///   - emojis: the custom emojis used in the HTML, provided with shortcode values between ":"
    /// - Returns: the NSAttributedString. Otherwise a string with no attributes if any errors are encountered rendering
    public func createStringFrom(html: String,
                                 emojis: [Emoji]) -> NSAttributedString {
        
        // TODO: - Make this work for AppKit! // swiftlint:disable:this todo
        return NSAttributedString(string: html.description)
    }
}

#endif
