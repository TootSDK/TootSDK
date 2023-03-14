//
//  BaseTimelineQuery.swift
//  
//
//  Created by dave on 12/03/23.
//

import Foundation

public protocol TimelineQuery: Hashable {
    func getQueryItems() -> [URLQueryItem]
}
