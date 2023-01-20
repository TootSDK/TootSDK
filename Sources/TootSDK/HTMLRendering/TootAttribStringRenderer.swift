//  TootAttribStringRenderer.swift
//  Created by dave on 23/12/22.

import Foundation

/// Public protocol to define an attributedStringRenderer
/// Clients can submit their own to TootClient via 
public protocol TootAttribStringRenderer {
    func render(html: String, emojis: [Emoji]) throws -> TootContent
    func render(_ post: Post) -> TootContent
}

/// This is a stub and should never be used in production. In the event of a renderer not existing already for the environment you're in (AppKit, Linux) we fail over to this implementation
public class NullAttribStringRenderer: TootAttribStringRenderer {
    /// parses a string as an html document using the system behaviour
    internal static func createAttributedString(_ html: String) throws -> NSAttributedString {
        guard let data = html.data(using: .utf8) else { return NSAttributedString() }
        return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    }
    
    public func render(html: String, emojis: [Emoji]) throws -> TootContent {
        return TootContent(wrappedValue: html, plainContent: HTML.stripHTMLFormatting(html: html) ?? "", attributedString: try Self.createAttributedString(html), systemAttributedString: try Self.createAttributedString(html))
    }
    
    public func render(_ post: Post) -> TootContent {
        do {
            return try render(html: post.content ?? "", emojis: post.emojis)
        } catch {
            print("TootSDK(NullAttribStringRenderer): Failed to render post: \(String(describing: error))")
            return .init(wrappedValue: "", plainContent: "", attributedString: .init(string: ""), systemAttributedString: .init(string: ""))
        }
    }
}
