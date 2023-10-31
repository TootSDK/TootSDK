//
//  PixelfedReportParams.swift
//  
//
//  Created by Łukasz Rutkowski on 31/10/2023.
//

import Foundation

/// Parameters to report a post on Pixelfed.
public struct PixelfedReportParams: Codable {

    /// Type of reported object (post or user).
    public var objectType: ObjectType
    /// ID of reported object.
    public var objectId: String
    /// Type of report.
    public var type: ReportType

    public init(objectType: ObjectType, objectId: String, type: ReportType) {
        self.objectType = objectType
        self.objectId = objectId
        self.type = type
    }

    public enum ReportType: String, Codable {
        case spam
        case sensitive
        case abusive
        case underage
        case violence
        case copyright
        case impersonation
        case scam
        case terrorism
    }

    public enum ObjectType: String, Codable {
        case post
        case user
    }

    private enum CodingKeys: String, CodingKey {
        case objectType = "object_type"
        case objectId = "object_id"
        case type = "report_type"
    }
}
