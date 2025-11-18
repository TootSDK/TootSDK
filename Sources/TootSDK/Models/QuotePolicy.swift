//
//  QuotePolicy.swift
//  TootSDK
//
//  Created by nixzhu on 11/18/25.
//

public enum QuotePolicy: String, CaseIterable, Codable, Sendable {
    /// Anybody can quote
    case `public`
    /// Only followers can quote
    case followers
    /// Just me (only the author will be able to quote)
    case nobody
}
