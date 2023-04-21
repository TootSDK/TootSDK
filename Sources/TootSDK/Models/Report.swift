// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

/// Reports filed against users and/or posts, to be taken action on by moderators.
public struct Report: Codable, Hashable, Identifiable {
    public var id: String
    public var actionTaken: Bool?
    public var actionTakenAt: Date?
    public var comment: String?
}
