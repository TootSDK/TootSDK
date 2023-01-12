//
//  TootClient+HTML.swift
//  
//
//  Created by dave on 23/12/22.
//

import Foundation

extension TootClient {
    /// Sets the renderer for generating attributed strings from HTML, defaults to DefaultTootAttributedStringRenderer
    public func setAttributedStringRenderer(_ renderer: TootAttribStringRenderer) {
        HTML.attributedStringRenderer = renderer
    }
    
    /// Returns the current attributed string renderer
    public func getRenderer() -> TootAttribStringRenderer {
        return HTML.attributedStringRenderer
    }
}
