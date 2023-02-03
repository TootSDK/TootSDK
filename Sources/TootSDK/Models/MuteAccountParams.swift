//
//  MuteAccountParams.swift
//  
//
//  Created by dave on 21/12/22.
//

import Foundation

public struct MuteAccountParams: Codable {
    public var notifications: Bool = true
    public var duration: Int = 0
    
    /// - Parameters:
    ///   - notifications: Mute notifications in addition to posts? Defaults to true.
    ///   - duration: How long the mute should last, in seconds. Defaults to 0 (indefinite).
    public init(notifications: Bool = true,
                duration: Int = 0) {
        self.notifications = notifications
        self.duration = duration
    }
}
