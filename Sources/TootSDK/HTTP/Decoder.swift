// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

public final class TootDecoder: JSONDecoder, @unchecked Sendable {
    internal override init() {
        super.init()

        keyDecodingStrategy = .convertFromSnakeCase
        dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            guard
                let date = Self.dateFormatter.date(from: dateString) ?? Self.dateFormatterWithoutFractionalSeconds.date(from: dateString)
                    ?? Self.dateFormatterWithFullDate.date(from: dateString)
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription:
                        "Error parsing date: '\(dateString)'")
            }

            return date
        }
    }
}

extension TootDecoder {
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

    static let dateFormatterWithFullDate: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        return dateFormatter
    }()
}
