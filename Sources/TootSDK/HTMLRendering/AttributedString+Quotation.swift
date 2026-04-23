//
//  AttributedString+Quotation.swift
//  TootSDK
//

import Foundation

/// Returns the opening and closing quotation mark strings for the given nesting level and locale.
///
/// - Even levels use the locale's primary delimiter pair; odd levels use the alternate pair.
/// - French (`fr`) appends a non-breaking space (U+00A0) inside each mark; Swiss variants
///   are intentionally excluded by checking the language code only.
/// - Falls back to `"` / `'` when the locale provides no delimiter for a given pair.
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
func quotationDelimiters(level: Int, locale: Locale) -> (open: String, close: String) {
    let langCode = locale.identifier.components(separatedBy: CharacterSet(charactersIn: "_-")).first ?? ""
    let isFrench = langCode == "fr"
    let nbsp = "\u{00A0}"

    let open: String
    let close: String

    if level % 2 == 0 {
        open = locale.quotationBeginDelimiter ?? "\u{201C}"
        close = locale.quotationEndDelimiter ?? "\u{201D}"
    } else {
        open = locale.alternateQuotationBeginDelimiter ?? "\u{2018}"
        close = locale.alternateQuotationEndDelimiter ?? "\u{2019}"
    }

    if isFrench {
        return (open + nbsp, nbsp + close)
    }
    return (open, close)
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension AttributedString {
    /// Wraps `content` in locale-correct quotation marks for the given nesting level.
    ///
    /// Inner text is not smartened; use a dedicated typography pass for that.
    public static func inlineQuotation(
        _ content: AttributedString,
        level: Int = 0,
        locale: Locale = .current
    ) -> AttributedString {
        let (open, close) = quotationDelimiters(level: level, locale: locale)
        return AttributedString(open) + content + AttributedString(close)
    }

    /// Wraps `content` in locale-correct quotation marks for the given nesting level.
    ///
    /// Inner text is not smartened; use a dedicated typography pass for that.
    public static func inlineQuotation(
        _ content: String,
        level: Int = 0,
        locale: Locale = .current
    ) -> AttributedString {
        let (open, close) = quotationDelimiters(level: level, locale: locale)
        return AttributedString(open + content + close)
    }
}
