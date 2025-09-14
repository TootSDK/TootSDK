//
//  ReportCategory.swift
//
//
//  Created by Łukasz Rutkowski on 01/11/2023.
//

import Foundation

public enum ReportCategory: String, CaseIterable, Codable, Sendable {
    case spam
    /// Content that is illegal in the user's or the instance's country.
    case legal
    case sensitive
    case abusive
    case underage
    case violence
    case copyright
    case impersonation
    case scam
    case terrorism
    case other
    case violation

    public static let pixelfedSupported: Set<ReportCategory> = [
        .spam,
        .sensitive,
        .abusive,
        .underage,
        .violence,
        .copyright,
        .impersonation,
        .scam,
        .terrorism,
    ]

    public static let mastodonSupported: Set<ReportCategory> = [
        .spam,
        .legal,
        .other,
        .violation,
    ]
}
