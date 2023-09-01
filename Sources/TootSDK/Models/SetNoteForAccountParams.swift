//
//  SetNoteForAccountParams.swift
//
//
//  Created by Philip Chu on 8/21/23.
//

import Foundation

public struct SetNoteForAccountParams: Codable, Sendable {
    public var comment: String?

    /// - Parameters:
    ///   - comment: The comment to be set on that user. Provide an empty string or leave out this parameter to clear the currently set note.
    public init(comment: String? = nil) {
        self.comment = comment
    }
}
