// Created by konstantin on 05/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation
import WebURL

public struct Pagination {
    public var prev: PagedInfo?
    public var next: PagedInfo?
}

extension Pagination {
    public static let paginationTypes: [String] = ["prev", "next"]

    public init(links: String) {
        let links = links.components(separatedBy: ",").map({
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        })

        let paginationItems: [(String, PagedInfo)] = links.compactMap { link in
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
                return nil
            }

            guard let referenceKey = rel?.first else {
                print("TootSDK: invalid pagination Link (referenceKey): '\(link)'")
                return nil
            }

            guard let referenceValue = rel?.last else {
                print("TootSDK: invalid pagination Link (referenceValue): '\(link)'")
                return nil
            }

            guard referenceKey == "rel" else {
                print("TootSDK: invalid pagination Link (rel): '\(link)'")
                return nil
            }

            guard Self.paginationTypes.contains(referenceValue) else {
                print("TootSDK: invalid pagination Link (paginationType): '\(link)'")
                return nil
            }

            guard let webURL = WebURL(validURL) else {
                print("TootSDK: invalid pagination Link (query): '\(link)'")
                return nil
            }

            let params = webURL.formParams
            let pagedInfo = PagedInfo(
                maxId: params.get("max_id"),
                minId: params.get("min_id"),
                sinceId: params.get("since_id")
            )
            return (referenceValue, pagedInfo)
        }

        prev = paginationItems.first(where: { $0.0 == "prev" })?.1
        next = paginationItems.first(where: { $0.0 == "next" })?.1
    }
}

func trim(left: Character, right: Character) -> (String) -> String {
    return { string in
        guard string.hasPrefix("\(left)"), string.hasSuffix("\(right)") else { return string }
        return String(
            string[string.index(after: string.startIndex)..<string.index(before: string.endIndex)])
    }
}
