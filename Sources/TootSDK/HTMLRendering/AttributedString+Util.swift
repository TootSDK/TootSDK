//
//  AttributedString+Util.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 06/11/2024.
//

import Foundation

#if canImport(UIKit)
    import UIKit

    typealias _Font = UIFont
#elseif canImport(AppKit)
    import AppKit

    typealias _Font = NSFont
#endif

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension AttributedString {
    mutating func insertInlinePresentationIntent(_ intent: InlinePresentationIntent) {
        for run in runs {
            if let intents = run.inlinePresentationIntent {
                self[run.range].inlinePresentationIntent = intents.union(intent)
            } else {
                self[run.range].inlinePresentationIntent = intent
            }
        }
    }

    #if canImport(UIKit) || canImport(AppKit)
        mutating func applyFontKeepingSymbolicTraits(_ font: _Font) {
            for run in runs {
                if let existingFontTraits = run.font?.fontDescriptor.symbolicTraits {
                    if let updatedFont = try? font.asTraits(existingFontTraits) {
                        self[run.range].font = updatedFont
                    }
                } else {
                    self[run.range].font = font
                }
            }
        }
    #endif

    mutating func trimWhitespaceAndNewlines() {
        var startIndex = startIndex
        while startIndex < endIndex && characters[startIndex].isWhitespaceOrNewline {
            startIndex = index(afterCharacter: startIndex)
        }

        var endIndex = endIndex
        while endIndex > startIndex && characters[index(beforeCharacter: endIndex)].isWhitespaceOrNewline {
            endIndex = index(beforeCharacter: endIndex)
        }

        self = AttributedString(self[startIndex..<endIndex])
    }

    var endsWithNewline: Bool {
        characters.last?.isNewline == true
    }

    var endsWithDoubleNewline: Bool {
        characters.count >= 2 && characters.suffix(2).allSatisfy(\.isNewline)
    }

    var string: String {
        String(characters[...])
    }
}

extension Character {
    var isWhitespaceOrNewline: Bool {
        isWhitespace || isNewline
    }
}
