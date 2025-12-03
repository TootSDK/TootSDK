//
//  AsyncRefreshHint.swift
//  TootSDK
//
//  Created by Dale Price on 11/3/25.
//

import Foundation
import StructuredFieldValues

/// Represents a hint that the client can or should asynchronously refresh the results of an API call.
///
/// - Warning: This currently follows the [Mastodon async refreshes v1 alpha](https://docs.joinmastodon.org/methods/async_refreshes/) format.
public struct _AsyncRefreshHint: Sendable, Hashable, Codable, Identifiable {

    /// The ID of the async refresh.
    public var id: String

    /// Minimum number of seconds that the client should wait before retrying the same endpoint or querying this one.
    public var retry: Int

    /// Number of results already created or fetched as part of this async refresh.
    public var resultCount: Int?

    public enum CodingKeys: String, CodingKey {
        case id
        case retry
        case resultCount = "result_count"
    }

    public init(id: String, retry: Int, resultCount: Int? = nil) {
        self.id = id
        self.retry = retry
        self.resultCount = resultCount
    }
}

extension _AsyncRefreshHint: StructuredFieldValue {
    public static let structuredFieldType = StructuredFieldType.dictionary
}
