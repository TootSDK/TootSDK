// Created by konstantin on 05/11/2022.
// Copyright (c) 2022. All rights reserved.

extension String {
    func condensed(separator: String = "") -> String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: separator)
    }
}
