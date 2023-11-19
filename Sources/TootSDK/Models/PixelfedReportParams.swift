//
//  PixelfedReportParams.swift
//
//
//  Created by Łukasz Rutkowski on 31/10/2023.
//

import Foundation

struct PixelfedReportParams: Codable {
    var objectType: ObjectType
    var objectId: String
    var type: ReportCategory

    enum ObjectType: String, Codable {
        case post
        case user
    }

    private enum CodingKeys: String, CodingKey {
        case objectType = "object_type"
        case objectId = "object_id"
        case type = "report_type"
    }
}
