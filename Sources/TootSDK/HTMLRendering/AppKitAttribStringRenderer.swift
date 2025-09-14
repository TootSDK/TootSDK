//  AppKitAttribStringRenderer.swift
//  Created by dave on 28/12/22.

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import Foundation
    import AppKit
    import WebURL
    import WebURLFoundationExtras
    import SwiftSoup

    public class AppKitAttribStringRenderer {

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

            return try renderHTML(html: html, emojis: emojis)
        }

        /// Renders the provided HTML string
        /// - Parameters:
        ///   - html: html description
        ///   - emojis: the custom emojis used in the HTML, provided with shortcode values between ":"
        /// - Returns: an instance `TootContent` with various representations of the content
        private func renderHTML(html: String, emojis: [Emoji]) throws -> TootContent {
            var html = html
            // attempt to parse emojis and other special content
            // Replace the custom emojis with image refs
            for emoji in emojis {
                html = html.replacingOccurrences(
                    of: ":" + emoji.shortcode + ":",
                    with: "<img src='" + emoji.staticUrl + "' alt='" + emoji.shortcode + "' data-tootsdk-emoji='true'>")
            }

            let plainText = TootHTML.extractAsPlainText(html: html) ?? ""

            if let doc = try? SwiftSoup.parseBodyFragment(html),
                let body = doc.body(),
                let attributedText = attributedTextForHTMLNode(body)
            {
                let mutAttrString = NSMutableAttributedString(attributedString: attributedText)
                mutAttrString.trimCharactersInSet(charSet: .whitespacesAndNewlines)
                return TootContent(wrappedValue: html, plainContent: plainText, attributedString: mutAttrString)
            } else {
                return TootContent(wrappedValue: html, plainContent: plainText, attributedString: NSAttributedString(string: html))
            }
        }

        private func createAttributedString(_ html: String) throws -> NSAttributedString {
            guard let data = html.data(using: .utf8) else { return NSAttributedString() }
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }

        private func attributedTextForHTMLNode(_ node: Node) -> NSAttributedString? {
            switch node {
            case let node as TextNode:
                return NSAttributedString(string: node.text())
            case let node as Element:
                return attributedTextForElement(node)
            default:
                return nil
            }
        }

        private func attributedTextForElement(_ element: Element) -> NSAttributedString? {
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
                attributed.addAttribute(
                    .strikethroughStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: attributed.fullRange())
            case "ol", "ul":
                attributed.append(NSAttributedString(string: "\n\n"))
                attributed.trimCharactersInSet(charSet: .whitespacesAndNewlines)
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
            guard (try? element.attr("src")) != nil else { return nil }
            if (try? element.attr("data-tootsdk-emoji")) != nil, let alt = try? element.attr("alt") {
                // fallback to the the :short_code
                return NSAttributedString(string: ":" + alt)
            }

            return NSAttributedString(string: try element.html())
        }

        private func attributedTextForHref(_ element: Element, attributed: inout NSMutableAttributedString) {
            guard let href = try? element.attr("href") else { return }

            if let webURL = WebURL(href),
                let url = URL(webURL)
            {
                attributed.addAttribute(.link, value: url, range: attributed.fullRange())
            } else if let url = URL(string: href) {
                attributed.addAttribute(.link, value: url, range: attributed.fullRange())
            }
        }

        private func updateAttributedTextForItalic(_ element: Element, attributed: inout NSMutableAttributedString) {
            if attributed.length > 0,
                let fontInAttributes = attributed.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
            {
                try? attributed.addAttribute(.font, value: fontInAttributes.asItalic(), range: attributed.fullRange())
            } else {
                // try? attributed.addAttribute(.font, value: config.font.asItalic(), range: attributed.fullRange())
            }
        }

        private func updateAttributedTextForBold(_ element: Element, attributed: inout NSMutableAttributedString) {
            if attributed.length > 0,
                let fontInAttributes = attributed.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
            {
                try? attributed.addAttribute(.font, value: fontInAttributes.asBold(), range: attributed.fullRange())
            } else {
                // try? attributed.addAttribute(.font, value: config.font.asBold(), range: attributed.fullRange())
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
                print("TootSDK(AppKitAttribStringRenderer): Failed to render post: \(String(describing: error))")
                return .init(wrappedValue: "", plainContent: "", attributedString: .init(string: ""))
            }
        }
    }

    extension NSMutableAttributedString {
        func fullRange() -> NSRange {
            return NSRange(location: 0, length: self.length)
        }
    }

    extension NSAttributedString {
        public func attributedStringByTrimmingCharacterSet(charSet: CharacterSet) -> NSAttributedString {
            let modifiedString = NSMutableAttributedString(attributedString: self)
            modifiedString.trimCharactersInSet(charSet: charSet)
            return NSAttributedString(attributedString: modifiedString)
        }
    }

    extension NSMutableAttributedString {
        public func trimCharactersInSet(charSet: CharacterSet) {
            var range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)

            // Trim leading characters from character set.
            while range.length != 0 && range.location == 0 {
                replaceCharacters(in: range, with: "")
                range = (string as NSString).rangeOfCharacter(from: charSet)
            }

            // Trim trailing characters from character set.
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
            while range.length != 0 && NSMaxRange(range) == length {
                replaceCharacters(in: range, with: "")
                range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
            }
        }
    }

#endif
