//
//  ReportParams.swift
//  
//
//  Created by Łukasz Rutkowski on 31/10/2023.
//

import Foundation

/// Parameters to report a post.
public struct ReportParams {
    /// ID of the account to report.
    public var accountId: String

    /// IDs of reported posts for additional context.
    public var postIds: [String]

    /// The reason for the report. Default maximum of 1000 characters.
    public var comment: String?

    /// If the account is remote, should the report be forwarded to the remote admin? Defaults to `false`.
    public var forward: Bool?

    /// Specify if the report is due to spam, violation of enumerated instance rules, or some other reason. Will be set to `violation` if `ruleIds` is provided (regardless of any category value you provide).
    public var category: ReportCategory

    /// For violation category reports, specify the ID of the exact rules broken.
    public var ruleIds: [Int]

    public init(
        accountId: String,
        category: ReportCategory,
        postIds: [String] = [],
        comment: String? = nil,
        forward: Bool? = nil,
        ruleIds: [Int] = []
    ) {
        self.accountId = accountId
        self.postIds = postIds
        self.comment = comment
        self.forward = forward
        self.category = category
        self.ruleIds = ruleIds
    }
}
