//
//  StatusSource.swift
//  
//
//  Created by dave on 4/12/22.
//

import Foundation

public struct StatusSource: Codable {
    var id: String
    var text: String
    var spoilerText: String

    public init(id: String, text: String, spoilerText: String) {
        self.id = id
        self.text = text
        self.spoilerText = spoilerText
    }
}
