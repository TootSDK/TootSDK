//
//  BlockQuoteStyle.swift
//  TootSDK
//

import Foundation

/// Controls how blockquote elements are rendered by `AttributedStringRenderer`.
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public struct BlockQuoteStyle: Sendable {
    /// The locale used to determine quotation mark characters.
    public var locale: Locale
    /// Attributes applied to the opening and closing quotation mark glyphs only.
    public var markAttributes: AttributeContainer
    /// Attributes merged into every run of body text, with inner element attributes taking precedence.
    public var contentAttributes: AttributeContainer

    public init(
        locale: Locale = .current,
        markAttributes: AttributeContainer = .init(),
        contentAttributes: AttributeContainer = .init()
    ) {
        self.locale = locale
        self.markAttributes = markAttributes
        self.contentAttributes = contentAttributes
    }

    /// Bare locale-aware quotation marks with no additional styling.
    public static let `default` = BlockQuoteStyle()
}
