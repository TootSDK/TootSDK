//
//  FeatureTagParams.swift
//
//
//  Created by Philip Chu on 6/10/23.
//

import Foundation

/// Params to feature a hashtag
public struct FeatureTagParams: Codable {
    /// The hashtag to be featured, without the hash sign.
    public var name: String

    public init(name: String) {
        self.name = name
    }
}
