//
//  NSAttributedString+helpers.swift

#if canImport(UIKit)
import Foundation

/// Trimming functions
extension NSMutableAttributedString {

    internal func trimLeadingCharactersInSet(_ charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet)

        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet)
        }
    }

    internal func trimTrailingCharactersInSet(_ charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)

        while range.length != 0 && range.length + range.location == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
        }
    }

}

///  Range helper
extension NSAttributedString {

    internal var fullRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }

}
#endif
