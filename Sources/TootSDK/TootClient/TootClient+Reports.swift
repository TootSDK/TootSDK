//
//  TootClient+Reports.swift
//  
//
//  Created by Łukasz Rutkowski on 26/10/2023.
//

import Foundation

public extension TootClient {

    /// Report problematic users or posts to moderators.
    ///
    /// - Warning: For Pixelfed use `PixelfedReportParams`.
    @discardableResult
    func report(_ params: ReportParams) async throws -> Report {
        try requireFlavour(otherThan: [.pixelfed])
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "reports"])
            $0.method = .post
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        return try await fetch(Report.self, req)
    }

    /// Report problematic users or posts to moderators.
    ///
    /// - Warning: For flavours other than Pixelfed use `ReportParams`.
    func report(_ params: PixelfedReportParams) async throws {
        try requireFlavour([.pixelfed])
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1.1", "report"])
            $0.method = .post
            $0.body = try .json(params)
        }
        _ = try await fetch(req: req)
    }
}

extension TootClient {
    internal func createQuery(from params: ReportParams) -> [URLQueryItem] {
        var queryItems = [
            URLQueryItem(name: "account_id", value: params.accountId)
        ]
        for postId in params.postIds {
            queryItems.append(URLQueryItem(name: "status_ids[]", value: postId))
        }
        if let comment = params.comment {
            queryItems.append(.init(name: "comment", value: comment))
        }
        if let forward = params.forward {
            queryItems.append(.init(name: "forward", value: String(forward).lowercased()))
        }
        if let category = params.category {
            queryItems.append(.init(name: "category", value: category))
        }
        for ruleId in params.ruleIds ?? [] {
            queryItems.append(.init(name: "rule_ids[]", value: String(ruleId)))
        }
        return queryItems
    }
}
