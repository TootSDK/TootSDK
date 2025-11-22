//
//  AttributedStringRenderer.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 05/11/2024.
//

#if canImport(UIKit) || canImport(AppKit)
import Foundation
import SwiftSoup
import WebURL

/// Renders HTML fragments into `AttributedString` output, producing both
/// plain text and attributed versions. Supports options to skip certain
/// elements or apply special rendering behaviors.
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public class AttributedStringRenderer {
    public static let shared = AttributedStringRenderer()

    /// Configuration options that control how HTML is converted into attributed strings.
    /// Use these flags to skip invisibles, skip inline quotes, render ellipses,
    /// or apply combined presets like `.shortenLinks` or `.all`.
    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Skips rendering of elements marked as invisible in the HTML.
        public static let skipInvisibles = Options(rawValue: 1 << 0)
        /// Renders ellipsis characters at the end of elements marked with the "ellipsis" class.
        public static let renderEllipsis = Options(rawValue: 1 << 1)
        /// Omits inline quote elements with the "quote-inline" class.
        public static let skipInlineQuotes = Options(rawValue: 1 << 2)

        /// Convenience option that combines behaviors to skip invisibles and render ellipses used by Mastodon links.
        public static let shortenLinks: Options = [.skipInvisibles, .renderEllipsis]

        /// Enables all available rendering options.
        public static let all: Options = [
            .skipInvisibles,
            .renderEllipsis,
            .skipInlineQuotes
        ]
    }

    public init() {}

    /// Converts an HTML fragment into a `ParsedContent` structure.
    ///
    /// - Parameters:
    ///   - html: A raw HTML string to render.
    ///   - options: Rendering options affecting output behavior.
    /// - Returns: A parsed result containing the original HTML, plain text,
    ///   and attributed string representation.
    public func render(html: String, options: Options = []) -> ParsedContent {
        guard
            let document = try? SwiftSoup.parseBodyFragment(html),
            let body = document.body()
        else {
            let plainText = TootHTML.extractAsPlainText(html: html) ?? ""
            return ParsedContent(rawString: html, plainString: plainText, attributedString: .init(plainText))
        }

        var attributedString = renderHTMLNode(body, options: options)
        attributedString.trimWhitespaceAndNewlines()
        return ParsedContent(
            rawString: html,
            plainString: attributedString.string,
            attributedString: attributedString
        )
    }

    private func renderHTMLNode(_ node: Node, options: Options) -> AttributedString {
        switch node {
        case let node as TextNode:
            return AttributedString(node.getWholeText())
        case let node as Element:
            return renderHTMLElement(node, options: options)
        default:
            return ""
        }
    }

    private func renderHTMLElement(_ element: Element, options: Options) -> AttributedString {
        var attributedString = AttributedString()

        if element.hasClass("quote-inline") && options.contains(.skipInlineQuotes) {
            return attributedString
        }
        if element.hasClass("invisible") && options.contains(.skipInvisibles) {
            return attributedString
        }

        for child in element.getChildNodes() {
            if child.isBlockElement && child.previousSibling() != nil && !attributedString.endsWithNewline {
                // Each block element (including ones following inline elements) should start on new line
                attributedString += "\n"
            }
            attributedString += renderHTMLNode(child, options: options)
        }

        if element.hasClass("ellipsis") && options.contains(.renderEllipsis) {
            attributedString += "…"
        }

        switch element.tagName() {
        case "br", "p", "pre":
            attributedString += "\n"
        case "a":
            applyLink(from: element, to: &attributedString)
        case "em", "i":
            attributedString.insertInlinePresentationIntent(.emphasized)
        case "strong", "b":
            attributedString.insertInlinePresentationIntent(.stronglyEmphasized)
        case "del":
            attributedString.insertInlinePresentationIntent(.strikethrough)
        case "li":
            applyList(from: element, to: &attributedString)
        case "code":
            attributedString.insertInlinePresentationIntent(.code)

#if canImport(UIKit) || canImport(AppKit)
        case "h1":
            attributedString.applyFontKeepingSymbolicTraits(.preferredFont(forTextStyle: .title1))
        case "h2":
            attributedString.applyFontKeepingSymbolicTraits(.preferredFont(forTextStyle: .title2))
        case "h3":
            attributedString.applyFontKeepingSymbolicTraits(.preferredFont(forTextStyle: .title3))
#endif

        default:
            break
        }

        if element.isBlockElement && !attributedString.endsWithDoubleNewline {
            // Insert up to 2 new lines after block elements
            attributedString += "\n"
        }

        return attributedString
    }

    private func applyLink(from element: Element, to attributedString: inout AttributedString) {
        guard let href = try? element.attr("href") else { return }

        if let webURL = WebURL(href), let url = URL(webURL) {
            attributedString.foundation.link = url
        } else if let url = URL(string: href) {
            attributedString.foundation.link = url
        }
    }

    private func applyList(from element: Element, to attributedString: inout AttributedString) {
        let level = element.parents().filter({ $0.tagName() == "ul" || $0.tagName() == "ol" }).count
        guard let parentTag = element.parent()?.tagName() else {
            return
        }
        let bullet: AttributedString

        switch parentTag {
        case "ol":
            let index = (try? element.elementSiblingIndex()) ?? 0
            bullet = AttributedString("\(index + 1).\t")
        case "ul":
            bullet = AttributedString("\u{2022}\t")
        default:
            bullet = AttributedString()
        }

        let indent = AttributedString(String(repeating: "\t", count: level - 1))
        attributedString = indent + bullet + attributedString
    }
}

extension Node {
    var isBlockElement: Bool {
        guard let element = self as? Element else {
            return false
        }
        return element.isBlock() && element.tagName() != "del"
    }
}
#endif
