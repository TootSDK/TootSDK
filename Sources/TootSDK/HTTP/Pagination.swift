// Created by konstantin on 05/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation
import WebURL

public struct Pagination {
    public var maxId: String?
    public var minId: String?
    public var sinceId: String?
}

public extension Pagination {
    static let paginationTypes: [String] = ["prev", "next"]

    init(links: String) {
        let links = links.components(separatedBy: ",").map({
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        })

        let paginationQueryItems: [URLQueryItem] = links.compactMap({ link in
            let segments =
                link
                .condensed()
                .components(separatedBy: ";")
            let url = segments.first.map(trim(left: "<", right: ">"))
            let rel = segments.last?
                .replacingOccurrences(of: "\"", with: "")
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: "=")

            guard let validURL = url else {
                print("TootSDK: invalid pagination Link (url): '\(link)'")
                return []
            }

            guard let referenceKey = rel?.first else {
                print("TootSDK: invalid pagination Link (referenceKey): '\(link)'")
                return []
            }

            guard let referenceValue = rel?.last else {
                print("TootSDK: invalid pagination Link (referenceValue): '\(link)'")
                return []
            }

            guard referenceKey == "rel" else {
                print("TootSDK: invalid pagination Link (rel): '\(link)'")
                return []
            }

            guard Self.paginationTypes.contains(referenceValue) else {
                print("TootSDK: invalid pagination Link (paginationType): '\(link)'")
                return []
            }

            guard let webURL = WebURL(validURL) else {
                print("TootSDK: invalid pagination Link (query): '\(link)'")
                return []
            }

            return webURL.formParams.allKeyValuePairs.map({URLQueryItem(name: $0.0, value: $0.1)})
        }).reduce([], +)

        minId = paginationQueryItems.first { $0.name == "min_id" }?.value
        maxId = paginationQueryItems.first { $0.name == "max_id" }?.value
        sinceId = paginationQueryItems.first { $0.name == "since_id" }?.value
    }
}

func trim(left: Character, right: Character) -> (String) -> String {
    return { string in
        guard string.hasPrefix("\(left)"), string.hasSuffix("\(right)") else { return string }
        return String(
            string[string.index(after: string.startIndex)..<string.index(before: string.endIndex)])
    }
}
