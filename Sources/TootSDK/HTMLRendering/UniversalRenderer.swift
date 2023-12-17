// Created by konstantin on 30/01/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import SwiftSoup
import WebURL
import WebURLFoundationExtras

/// A simple renderer to adapt HTML content including custom emojis or render them as plain text
public class UniversalRenderer {

    public init() {}

    /// Renders the provided HTML string
    /// - Parameters:
    ///   - html: html description
    ///   - emojis: the custom emojis used in the HTML, provided with shortcode values between ":"
    /// - Returns: an instance `TootContent` with various representations of the content
    public func render(
        html: String?,
        emojis: [Emoji]
    ) throws -> TootContent {

        guard let html = html else {
            return TootContent(wrappedValue: "", plainContent: "", attributedString: NSAttributedString(string: ""))
        }

        return try render(html: html, emojis: emojis)
    }

    /// Renders the provided HTML string
    /// - Parameters:
    ///   - html: html description
    ///   - emojis: the custom emojis used in the HTML, provided with shortcode values between ":"
    /// - Returns: an instance `TootContent` with various representations of the content
    public func render(
        html: String,
        emojis: [Emoji]
    ) throws -> TootContent {

        let plainText = TootHTML.extractAsPlainText(html: html) ?? ""

        var html = html

        // attempt to parse emojis and other special content
        // Replace the custom emojis with image refs and a data attribute which can be used in css:
        emojis.forEach { emoji in
            html = html.replacingOccurrences(
                of: ":" + emoji.shortcode + ":", with: "<img src='" + emoji.staticUrl + "' alt='" + emoji.shortcode + "' data-tootsdk-emoji='true'>")
        }

        return TootContent(wrappedValue: html, plainContent: plainText, attributedString: NSAttributedString(string: html))
    }

    /// Renders a post into TootContent
    /// - Parameter tootPost: the post to render
    /// - Returns: the TootContent constructed
    public func render(_ tootPost: Post) -> TootContent {
        do {
            return try render(html: tootPost.content ?? "", emojis: tootPost.emojis)
        } catch {
            print("TootSDK(UniversalRenderer): Failed to render post: \(String(describing: error))")
            return .init(wrappedValue: "", plainContent: "", attributedString: .init(string: ""))
        }
    }
}
