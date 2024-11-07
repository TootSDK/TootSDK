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

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    public class AttributedStringRenderer {
        public static let shared = AttributedStringRenderer()

        public init() {}

        public func render(html: String) -> ParsedContent {
            guard
                let document = try? SwiftSoup.parseBodyFragment(html),
                let body = document.body()
            else {
                let plainText = TootHTML.extractAsPlainText(html: html) ?? ""
                return ParsedContent(rawString: html, plainString: plainText, attributedString: .init(plainText))
            }

            var attributedString = renderHTMLNode(body)
            attributedString.trimWhitespaceAndNewlines()
            return ParsedContent(
                rawString: html,
                plainString: attributedString.string,
                attributedString: attributedString
            )
        }

        private func renderHTMLNode(_ node: Node) -> AttributedString {
            switch node {
            case let node as TextNode:
                return AttributedString(node.getWholeText())
            case let node as Element:
                return renderHTMLElement(node)
            default:
                return ""
            }
        }

        private func renderHTMLElement(_ element: Element) -> AttributedString {
            var attributedString = AttributedString()

            for child in element.getChildNodes() {
                if child.isBlockElement && child.previousSibling() != nil && !attributedString.endsWithNewline {
                    // Each block element (including ones following inline elements) should start on new line
                    attributedString += "\n"
                }
                attributedString += renderHTMLNode(child)
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
                attributedString.link = url
            } else if let url = URL(string: href) {
                attributedString.link = url
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
