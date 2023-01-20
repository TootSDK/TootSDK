//
//  TootClient+HTML.swift
//  
//
//  Created by dave on 23/12/22.
//

import Foundation

extension TootClient {
    /// Creates a new instance of a renderer appropriate for the current platform. A renderer assists in presenting html toots in a native format like attributed string.
    public func getRenderer() -> TootAttribStringRenderer {
#if canImport(UIKit)
        return UIKitAttribStringRenderer()
#else
        return NullAttribStringRenderer()
#endif
    }
}
