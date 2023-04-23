//  UIKitAttribStringRenderer.swift
//  Created by dave on 28/12/22.

#if canImport(UIKit)
import Foundation
import UIKit
import WebURL
import WebURLFoundationExtras
import SwiftSoup

public class UIKitAttribStringRenderer {

    public init() {}

    /// Renders the provided HTML string
    /// - Parameters:
    ///   - html: html description
    ///   - emojis: the custom emojis used in the HTML, provided with shortcode values between ":"
    /// - Returns: an instance `TootContent` with various representations of the content
    public func render(html: String?,
                       emojis: [Emoji]) throws -> TootContent {

        guard let html = html else {
            return TootContent(wrappedValue: "", plainContent: "", attributedString: NSAttributedString(string: ""))
        }

        return try renderHTML(html: html, emojis: emojis)
    }

    // MARK: - Properties

    /// Renders the provided HTML string
    /// - Parameters:
    ///   - html: html description
    ///   - emojis: the custom emojis used in the HTML, provided with shortcode values between ":"
    /// - Returns: an instance `TootContent` with various representations of the content
    private func renderHTML(html: String,
                            emojis: [Emoji]) throws -> TootContent {
        var html = html

        // attempt to parse emojis and other special content
        // Replace the custom emojis with image refs
        emojis.forEach { emoji in
            html = html.replacingOccurrences(of: ":" + emoji.shortcode + ":", with: "<img src='" + emoji.staticUrl + "' alt='" + emoji.shortcode + "' data-tootsdk-emoji='true'>")
        }

        let plainText = TootHTML.extractAsPlainText(html: html) ?? ""

        if let doc = try? SwiftSoup.parseBodyFragment(html),
           let body = doc.body(),
           let attributedText = attributedTextForHTMLNode(body) {
            let mutAttrString = NSMutableAttributedString(attributedString: attributedText)
            mutAttrString.trimTrailingCharactersInSet(.whitespacesAndNewlines)

            return TootContent(wrappedValue: html, plainContent: plainText, attributedString: mutAttrString)
        } else {
            return TootContent(wrappedValue: html, plainContent: plainText, attributedString: NSAttributedString(string: html))
        }
    }

    private func attributedTextForHTMLNode(_ node: Node) -> NSAttributedString? {
        switch node {
        case let node as TextNode:
            return  NSAttributedString(string: node.text())
        case let node as Element:
            return attributedTextForElement(node)
        default:
            return nil
        }
    }

    private func attributedTextForElement(_ element: Element) -> NSAttributedString? {  // swiftlint:disable:this cyclomatic_complexity
        var attributed = NSMutableAttributedString(string: "")

        for child in element.getChildNodes() {
            /// Recursive appending
            if let childAttributed = attributedTextForHTMLNode(child) {
                attributed.append(childAttributed)
            }
        }

        switch element.tagName() {
        case "br":
            attributed.append(NSAttributedString(string: "\n"))
        case "p":
            attributed.append(NSAttributedString(string: "\n\n"))
        case "a":
            attributedTextForHref(element, attributed: &attributed)
        case "em", "i":
            updateAttributedTextForItalic(element, attributed: &attributed)
        case "strong", "b":
            updateAttributedTextForBold(element, attributed: &attributed)
        case "del":
            attributed.addAttribute(.strikethroughStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: attributed.fullRange)
        case "ol", "ul":
            attributed.append(NSAttributedString(string: "\n\n"))
            attributed.trimLeadingCharactersInSet(.whitespacesAndNewlines)
        case "li":
            updateAttributedTextForList(element, attributed: &attributed)
        case "img":
            if let imgAttr = try? attributedTextForImage(element) {
                attributed.append(imgAttr)
            }
        default:
            break
        }

        return attributed
    }

    private func attributedTextForImage(_ element: Element) throws -> NSAttributedString? {
        guard let _ = try? element.attr("src") else { return nil }
        if let _ = try? element.attr("data-tootsdk-emoji"), let alt = try? element.attr("alt") {
            // fallback to the the :short_code
            return NSAttributedString(string: ":" + alt)
        }

        return NSAttributedString(string: try element.html())
    }

    private func attributedTextForHref(_ element: Element, attributed: inout NSMutableAttributedString) {
        guard let href = try? element.attr("href") else { return }

        if let webURL = WebURL(href),
           let url = URL(webURL) {
            attributed.addAttribute(.link, value: url, range: attributed.fullRange)
        } else if let url = URL(string: href) {
            attributed.addAttribute(.link, value: url, range: attributed.fullRange)
        }
    }

    private func updateAttributedTextForItalic(_ element: Element, attributed: inout NSMutableAttributedString) {
        if attributed.length > 0,
           let fontInAttributes = attributed.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            try? attributed.addAttribute(.font, value: fontInAttributes.asItalic(), range: attributed.fullRange)
        } else {
            // try? attributed.addAttribute(.font, value: config.font.asItalic(), range: attributed.fullRange)
        }
    }

    private func updateAttributedTextForBold(_ element: Element, attributed: inout NSMutableAttributedString) {
        if attributed.length > 0,
           let fontInAttributes = attributed.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            try? attributed.addAttribute(.font, value: fontInAttributes.asBold(), range: attributed.fullRange)
        } else {
            // try? attributed.addAttribute(.font, value: config.font.asBold(), range: attributed.fullRange)
        }
    }

    private func updateAttributedTextForList(_ element: Element, attributed: inout NSMutableAttributedString) {
        if let parentTag = element.parent()?.tagName() {
            let bullet: NSAttributedString

            switch parentTag {
            case "ol":
                let index = (try? element.elementSiblingIndex()) ?? 0
                bullet = NSAttributedString(string: "\(index + 1).\t")
            case "ul":
                bullet = NSAttributedString(string: "\u{2022}\t")
            default:
                bullet = NSAttributedString()
            }

            attributed.insert(bullet, at: 0)
            attributed.append(NSAttributedString(string: "\n"))
        }
    }

    /// Renders a post into TootContent
    /// - Parameter tootPost: the post to render
    /// - Returns: the TootContent constructed
    public func render(_ tootPost: Post) -> TootContent {
        do {
            return try render(html: tootPost.content ?? "", emojis: tootPost.emojis)
        } catch {
            print("TootSDK(UIKitAttribStringRenderer): Failed to render post: \(String(describing: error))")
            return .init(wrappedValue: "", plainContent: "", attributedString: .init(string: ""))
        }
    }
}

#endif
