//
//  QuotePolicy.swift
//  TootSDK
//
//  Created by nixzhu on 11/18/25.
//

public enum QuotePolicy: String, CaseIterable, Codable, Sendable {
    case `public`
    case followers
    case nobody
}
