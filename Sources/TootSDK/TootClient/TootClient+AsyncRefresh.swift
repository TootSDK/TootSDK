//
//  TootClient+AsyncRefresh.swift
//  TootSDK
//
//  Created by Dale Price on 10/29/25.
//

import Foundation

extension TootClient {

    /// Query the status of a server-side async refresh job.
    /// - Parameter id: The ID of an active async refresh job, provided in the ``TootResponse/asyncRefresh`` property of the response to an API call.
    /// - Returns: An ``AsyncRefreshResponse`` instance representing the status of the job with the given ID.
    ///
    /// Expected to return `404` if there is no such job.
    ///
    /// - Warning: TootSDK currently only supports the alpha version of this endpoint as documented at [https://docs.joinmastodon.org/methods/async_refreshes/](https://docs.joinmastodon.org/methods/async_refreshes/).
    public func getAsyncRefresh(id: String) async throws -> AsyncRefreshResponse {
        let response = try await getAsyncRefreshRaw(id: id)
        return response.data
    }

    /// Query the status of a server-side async refresh job.
    /// - Parameter id: The ID of an active async refresh job, provided in the ``TootResponse/asyncRefresh`` property of the response to an API call.
    /// - Returns: A ``TootResponse`` containing the ``AsyncRefreshResponse`` representing the status of the job with the given ID.
    ///
    /// Expected to return `404` if there is no such job.
    ///
    /// - Warning: TootSDK currently only supports the alpha version of this endpoint as documented at [https://docs.joinmastodon.org/methods/async_refreshes/](https://docs.joinmastodon.org/methods/async_refreshes/).
    public func getAsyncRefreshRaw(id: String) async throws -> TootResponse<AsyncRefreshResponse> {
        try requireFeature(.asyncRefreshV1Alpha)

        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1_alpha", "async_refreshes", id])
            $0.method = .get
        }

        return try await fetchRaw(AsyncRefreshResponse.self, req)
    }
}

extension TootFeature {
    /// The ability to query the v1 alpha Async Refresh API.
    public static let asyncRefreshV1Alpha = TootFeature(requirements: [
        // TODO: When or if this feature moves out of alpha, we will need to add a maxDisplayVersion to this requirement, add an additional TootFeature for the final version, and update `getAsyncRefreshRaw` to use the appropriate version depending on the server version.
        .from(.mastodon, displayVersion: "4.4.0")
    ])
}
