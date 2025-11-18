//
//  QuotePolicy.swift
//  TootSDK
//
//  Created by nixzhu on 11/18/25.
//

import Foundation

public enum QuotePolicy: String, CaseIterable, Codable, Sendable {
    case `public`
    case followers
    case nobody
}
