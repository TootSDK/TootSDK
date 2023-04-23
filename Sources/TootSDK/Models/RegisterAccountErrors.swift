//
//  RegisterAccountErrors.swift
//
//
//  Created by Konstantin on 09/03/2023.
//

import Foundation

public struct RegisterAccountErrors: Codable, Sendable {
    /// A validation error message
    public let error: String?
}
