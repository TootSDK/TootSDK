//
//  Decoding+Helpers.swift
//  Created by Łukasz Rutkowski on 18/03/2023.
//

import Foundation

extension KeyedDecodingContainerProtocol {
    func decodeIntFromString(forKey key: Key) throws -> Int {
        do {
            return try decode(Int.self, forKey: key)
        } catch {
            let string = try decode(String.self, forKey: key)
            if let int = Int(string) {
                return int
            }
            throw error
        }
    }

    func decodeBoolFromString(forKey key: Key) throws -> Bool {
        do {
            return try decode(Bool.self, forKey: key)
        } catch {
            let string = try decode(String.self, forKey: key)
            if let bool = Bool(string) {
                return bool
            }
            throw error
        }
    }

    func decodeIntFromStringIfPresent(forKey key: Key) throws -> Int? {
        do {
            return try decodeIfPresent(Int.self, forKey: key)
        } catch {
            guard let string = try decodeIfPresent(String.self, forKey: key) else {
                return nil
            }
            if let int = Int(string) {
                return int
            }
            throw error
        }
    }
}
