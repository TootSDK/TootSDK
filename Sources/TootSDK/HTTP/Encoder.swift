// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public final class TootEncoder: JSONEncoder {
    public override init() {
        super.init()

        keyEncodingStrategy = .convertToSnakeCase
        dateEncodingStrategy = .custom { (date, encoder) in
            let stringData = Self.dateFormatter.string(from: date)
            var container = encoder.singleValueContainer()
            try container.encode(stringData)
        }
    }
}

internal extension TootEncoder {
    static let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()

        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return dateFormatter
    }()

    static let dateFormatterWithoutFractionalSeconds: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()

        dateFormatter.formatOptions = [.withInternetDateTime]

        return dateFormatter
    }()
}
