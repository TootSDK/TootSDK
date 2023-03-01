//
//  File.swift
//
//  Created by Dale Price on 3/1/23.
//

import Foundation

/// Specifies whether a timeline request should be restricted to local or remote statuses
public enum TimelineLocality: Codable, Sendable {
    /// Return only local statuses
    case local
    
    /// Return only remote statuses
    case remote
}
