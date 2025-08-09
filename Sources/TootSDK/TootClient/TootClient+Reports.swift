//
//  TootClient+Reports.swift
//
//
//  Created by Łukasz Rutkowski on 26/10/2023.
//

import Foundation

extension TootClient {

    /// Report problematic users or posts to moderators.
    public func report(_ params: ReportParams) async throws {
        if flavour == .pixelfed {
            try await pixelfedReport(params)
            return
        }

        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "reports"])
            $0.method = .post
            $0.body = try .form(queryItems: createQuery(from: params))
        }

        _ = try await fetch(req: req)
    }

    /// Report categories supported by current flavour.
    public var reportCategories: Set<ReportCategory> {
        if flavour == .pixelfed {
            return ReportCategory.pixelfedSupported
        }
        return ReportCategory.mastodonSupported
    }

    private func pixelfedReport(_ params: ReportParams) async throws {
        guard let category = params.category.value, ReportCategory.pixelfedSupported.contains(category) else {
            throw TootSDKError.invalidParameter(
                parameterName: "category",
                reason: "Unsupported category."
            )
        }
        let postId = params.postIds.first
        let pixelfedParams = PixelfedReportParams(
            objectType: .some(postId != nil ? .post : .user),
            objectId: postId ?? params.accountId,
            type: params.category
        )
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1.1", "report"])
            $0.method = .post
            $0.body = try .json(pixelfedParams, encoder: encoder)
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
        if let category = params.category.value, ReportCategory.mastodonSupported.contains(category) {
            queryItems.append(.init(name: "category", value: params.category.rawValue))
        }
        for ruleId in params.ruleIds {
            queryItems.append(.init(name: "rule_ids[]", value: String(ruleId)))
        }
        return queryItems
    }
}
