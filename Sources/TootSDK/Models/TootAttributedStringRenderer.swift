//
//  TootAttributedStringRenderer.swift
//  
//
//  Created by dave on 23/12/22.
//

import Foundation
import SwiftSoup
import UIKit
import WebURL
import WebURLFoundationExtras

/// Public protocol to define an attributedStringRenderer
/// Clients can submit their own to TootClient via 
public protocol TootAttributedStringRenderer {
    func createStringFrom(html: String, emojis: [Emoji]) -> NSAttributedString
}

public struct TootStringRenderConfig {
    /// Defaults to the current body font, if initialized with ()
    var font: UIFont
    
    /// Defaults to the current body font, rendered with monospaced if initialized with ()
    var monospaceFont: UIFont
    
    /// Defaults to UIColor.label,  if initialized with ()
    var color: UIColor
    
    /// Defaults to UIColor.link,  if initialized with ()
    var linkColor = UIColor.link
    
    /// Defaults to 2 line spacing, if initialized with ()
    var paragraphStyle: NSParagraphStyle
    
    /// Initialize with default values
    public init() {
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        font = bodyFont
        
        monospaceFont = UIFont.monospacedSystemFont(ofSize: bodyFont.pointSize,
                                                    weight: .regular)
        color = UIColor.label
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        paragraphStyle = style
    }
    
    /// Create a  rendering configuration
    /// - Parameters:
    ///   - font: the base font to use
    ///   - monospaceFont: the monospace font to use
    ///   - color:the main color of all text
    ///   - linkColor: the color of links
    ///   - paragraphStyle: the paragraph style for all text
    public init(font: UIFont,
                monospaceFont: UIFont,
                color: UIColor,
                linkColor: UIColor,
                paragraphStyle: NSParagraphStyle) {
        self.font = font
        self.monospaceFont = monospaceFont
        self.color = color
        self.paragraphStyle = paragraphStyle
        self.linkColor = linkColor
    }
    
}

public class DefaultTootAttributedStringRenderer: TootAttributedStringRenderer {
    
    let config: TootStringRenderConfig
    
    /// - Parameter config: the TootStringRenderConfig to use to render the text, defaults to the default values in TootStringRenderConfig unless you supply your own
    public init(config: TootStringRenderConfig = TootStringRenderConfig()) {
        self.config = config
    }
    
    /// Renders the HTML to an NSAttributedString
    /// - Parameters:
    ///   - html: html description
    ///   - emojis: the custom emojis used in the HTML, provided with shortcode values between ":"
    /// - Returns: the NSAttributedString. Otherwise a string with no attributes if any errors are encountered rendering
    public func createStringFrom(html: String,
                                 emojis: [Emoji]) -> NSAttributedString {
        var html = html
        
        // Replace the custom emojis with image refs
        emojis.forEach { emoji in
            html = html.replacingOccurrences(of: ":" + emoji.shortcode + ":", with: "<img src='" + emoji.staticUrl + "'>")
        }
        
        if let doc = try? SwiftSoup.parseBodyFragment(html),
           let body = doc.body(),
           let attributedText = attributedTextForHTMLNode(body) {
            let mutAttrString = NSMutableAttributedString(attributedString: attributedText)
            mutAttrString.trimTrailingCharactersInSet(.whitespacesAndNewlines)
            
            mutAttrString.addAttribute(.paragraphStyle,
                                       value: config.paragraphStyle,
                                       range: mutAttrString.fullRange)
            
            return mutAttrString
        } else {
            return NSAttributedString(string: html.description)
        }
    }
    
    private func attributedTextForHTMLNode(_ node: Node) -> NSAttributedString? {
        switch node {
        case let node as TextNode:
            return  NSAttributedString(string: node.text(), attributes: [.font: config.font, .foregroundColor: config.color])
        case let node as Element:
            return attributedTextForElement(node)
        default:
            return nil
        }
    }
    
    private func attributedTextForElement(_ element: Element) -> NSAttributedString? {  // swiftlint:disable:this cyclomatic_complexity
        var attributed = NSMutableAttributedString(string: "", attributes: [.font: config.font, .foregroundColor: config.color])
        
        for child in element.getChildNodes() {
            /// Recursive appending
            if let childAttributed = attributedTextForHTMLNode(child) {
                attributed.append(childAttributed)
            }
        }
        
        switch element.tagName() {
        case "br":
            attributed.append(NSAttributedString(string: "\n", attributes: [.font: config.font]))
        case "p":
            attributed.append(NSAttributedString(string: "\n\n", attributes: [.font: config.font]))
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
        case "code":
            attributed.addAttribute(.font,
                                    value: config.monospaceFont,
                                    range: attributed.fullRange)
        case "pre":
            attributed.append(NSAttributedString(string: "\n\n"))
            attributed.addAttribute(.font, value: config.monospaceFont,
                                    range: attributed.fullRange)
        case "ol", "ul":
            attributed.append(NSAttributedString(string: "\n\n"))
            attributed.trimLeadingCharactersInSet(.whitespacesAndNewlines)
        case "li":
            updateAttributedTextForList(element, attributed: &attributed)
        default:
            break
        }
        
        return attributed
    }
    
    private func attributedTextForHref(_ element: Element, attributed: inout NSMutableAttributedString) {
        guard let href = try? element.attr("href") else { return }
        
        if let webURL = WebURL(href),
           let url = URL(webURL) {
            attributed.addAttribute(.link, value: url, range: attributed.fullRange)
        } else if let url = URL(string: href) {
            attributed.addAttribute(.link, value: url, range: attributed.fullRange)
        }
        
        attributed.addAttribute(.foregroundColor, value: config.linkColor, range: attributed.fullRange)
    }
    
    private func updateAttributedTextForItalic(_ element: Element, attributed: inout NSMutableAttributedString) {
        if attributed.length > 0,
            let fontInAttributes = attributed.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            try? attributed.addAttribute(.font, value: fontInAttributes.asItalic(), range: attributed.fullRange)
        } else {
            try? attributed.addAttribute(.font, value: config.font.asItalic(), range: attributed.fullRange)
        }
    }
    
    private func updateAttributedTextForBold(_ element: Element, attributed: inout NSMutableAttributedString) {
        if attributed.length > 0,
           let fontInAttributes = attributed.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
           try? attributed.addAttribute(.font, value: fontInAttributes.asBold(), range: attributed.fullRange)
        } else {
            try? attributed.addAttribute(.font, value: config.font.asBold(), range: attributed.fullRange)
        }
    }
    
    private func updateAttributedTextForList(_ element: Element, attributed: inout NSMutableAttributedString) {
        if let parentTag = element.parent()?.tagName() {
            let bullet: NSAttributedString
            
            switch parentTag {
            case "ol":
                let index = (try? element.elementSiblingIndex()) ?? 0
                bullet = NSAttributedString(string: "\(index + 1).\t", attributes: [.font: config.monospaceFont,
                                                                                    .foregroundColor: config.color])
            case "ul":
                bullet = NSAttributedString(string: "\u{2022}\t", attributes: [.font: config.font,
                                                                               .foregroundColor: config.color])
            default:
                bullet = NSAttributedString()
            }
            
            attributed.insert(bullet, at: 0)
            attributed.append(NSAttributedString(string: "\n", attributes: [.font: config.font]))
        }
    }
}
