//
//  TootClient+HTML.swift
//  
//
//  Created by dave on 23/12/22.
//

#if canImport(UIKit)
import Foundation

extension TootClient {
    /// Sets the renderer for generating attributed strings from HTML, defaults to DefaultTootAttributedStringRenderer
    public func setAttributedStringRenderer(_ renderer: TootAttributedStringRenderer) {
        HTML.attributedStringRenderer = renderer
    }
}
#endif
