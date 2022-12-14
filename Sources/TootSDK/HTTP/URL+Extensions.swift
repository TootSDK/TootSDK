// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

extension URL {
    init?(unicodeString: String) {
        if let url = Self(string: unicodeString) {
            self = url
        } else if let escaped = unicodeString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            let colonUnescaped = escaped.replacingOccurrences(
                of: "%3A",
                with: ":",
                range: escaped.range(of: "%3A"))

            if let url = URL(string: colonUnescaped) {
                self = url
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
