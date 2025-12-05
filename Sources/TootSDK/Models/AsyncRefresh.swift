//
//  AsyncRefresh.swift
//  TootSDK
//
//  Created by Dale Price on 10/29/25.
//

import Foundation

/// Represents a response from ``TootClient/_getAsyncRefresh(id:)`` containing the current state of an Async Refresh task.
public struct _AsyncRefreshResponse: Sendable, Hashable, Codable {

    /// Current properties of an asynchronous refresh task on the server.
    public struct _AsyncRefresh: Sendable, Hashable, Codable, Identifiable {

        /// The status of an asynchronous refresh task on the server.
        public enum Status: String, Sendable, Codable, Hashable {
            /// A background job is still running to perform the async refresh, so new results may become available.
            case running
            /// The background job performing this async refresh has finished, so no new results should be expected from this job.
            case finished
        }

        /// The ID of the async refresh.
        public var id: String

        /// Status of the async refresh.
        public var status: OpenEnum<Status>

        /// Number of results already created or fetched as part of this async refresh.
        public var resultCount: Int?

        public init(id: String, status: Status, resultCount: Int? = nil) {
            self.id = id
            self.status = .some(status)
            self.resultCount = resultCount
        }
    }

    /// The current value of the async refresh.
    public var asyncRefresh: _AsyncRefresh

    public init(_ asyncRefresh: _AsyncRefresh) {
        self.asyncRefresh = asyncRefresh
    }
}
