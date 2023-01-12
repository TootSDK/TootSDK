//  TootAttribStringRenderer.swift
//  Created by dave on 23/12/22.

import Foundation

/// Public protocol to define an attributedStringRenderer
/// Clients can submit their own to TootClient via 
public protocol TootAttribStringRenderer {
    func createStringFrom(html: String, emojis: [Emoji]) -> NSAttributedString
    func render(_ post: Post) -> NSAttributedString
}

/// This is a stub and should never be used in production. In the event of a renderer not existing already for the environment you're in (AppKit, Linux) we fail over to this implementation
public class NullAttribStringRenderer: TootAttribStringRenderer {
    public func createStringFrom(html: String, emojis: [Emoji]) -> NSAttributedString {
        return NSAttributedString(string: html)
    }
    
    public func render(_ post: Post) -> NSAttributedString {
        return NSAttributedString(string: post.content ?? "")
    }
}
