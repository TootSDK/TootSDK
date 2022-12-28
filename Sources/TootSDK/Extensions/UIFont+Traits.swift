//
//  UIFont+Traits.swift
//
//  Via https://gist.github.com/mntone/9d742a1cbe18743e21c071600990c5d0

#if canImport(UIKit)
import CoreText
import class UIKit.UIFont
import class UIKit.UIFontDescriptor

extension UIFont {
    
    internal func asBold() throws -> UIFont {
        return try asTraits(.traitBold)
    }
    
    internal func asItalic() throws -> UIFont {
        return try asTraits(.traitItalic)
    }
    
    internal func asTraits(_ traits: UIFontDescriptor.SymbolicTraits) throws -> UIFont {
        if let fontDesc = self.fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: fontDesc, size: 0)
        } else {
            throw(TootSDKError.unexpectedError("blah"))
        }
    }
    
    internal func asMonospacedDigit() -> UIFont {
        return customized(by: [
            .typeIdentifier: kNumberSpacingType,
            .featureIdentifier: kMonospacedNumbersSelector
        ])
    }
    
    internal func customized(by features: [UIFontDescriptor.FeatureKey: Any]) -> UIFont {
        let fontDesc = self.fontDescriptor.addingAttributes([.featureSettings: features])
        return UIFont(descriptor: fontDesc, size: 0)
    }
}

#endif
