// Created by konstantin on 20/01/2023.
// Copyright (c) 2023. All rights reserved.

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import CoreText
import class AppKit.NSFont
import class AppKit.NSFontDescriptor

extension NSFont {
    
    internal func asBold() throws -> NSFont {
        return try asTraits(.bold)
    }
    
    internal func asItalic() throws -> NSFont {
        return try asTraits(.italic)
    }
    
    internal func asTraits(_ traits: NSFontDescriptor.SymbolicTraits) throws -> NSFont {
        let fontDesc = self.fontDescriptor.withSymbolicTraits(traits)
        if let font = NSFont(descriptor: fontDesc, size: 0) {
            return font
        } else {
            throw(TootSDKError.unexpectedError("blah"))
        }
    }
    
    internal func asMonospacedDigit() -> NSFont {
        return customized(by: [
            .typeIdentifier: kNumberSpacingType
        ])
    }
    
    internal func customized(by features: [NSFontDescriptor.FeatureKey: Any]) -> NSFont {
        let fontDesc = self.fontDescriptor.addingAttributes([.featureSettings: features])
        return NSFont(descriptor: fontDesc, size: 0)!
    }
}

#endif
