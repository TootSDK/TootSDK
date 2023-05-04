//
//  TootClient+Notifications.swift
//
//
//  Created by Konstantin on 04/05/2023.
//

import Foundation

public extension TootClient {

    /// Get all notifications concerning the user
    func getNotifications(params: TootNotificationParams = .init(), _ pageInfo: PagedInfo? = nil, limit: Int? = nil) async throws -> PagedResult<[TootNotification]> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications"])
            $0.method = .get
            $0.query = createQuery(from: params) + getQueryParams(pageInfo, limit: limit)
        }

        let (data, response) = try await fetch(req: req)
        let decoded = try decode([TootNotification].self, from: data)
        var pagination: Pagination?

        if let links = response.value(forHTTPHeaderField: "Link") {
            pagination = Pagination(links: links)
        }

        let info = PagedInfo(maxId: pagination?.maxId, minId: pagination?.minId, sinceId: pagination?.sinceId)

        return PagedResult(result: decoded, info: info)
    }

    /// Get info about a single notification
    func getNotification(id: String) async throws -> TootNotification {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", id])
            $0.method = .get
        }

        return try await fetch(TootNotification.self, req)
    }

    /// Clear all notifications from the server.
    func dismissAllNotifications() async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", "clear"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }

    /// Dismiss a single notification from the server.
    func dismissNotification(id: String) async throws {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "notifications", id, "dismiss"])
            $0.method = .post
        }

        _ = try await fetch(req: req)
    }

    func createQuery(from params: TootNotificationParams) -> [URLQueryItem] {
        var queryParameters = [URLQueryItem]()

        if let types = params.types, !types.isEmpty {
            queryParameters.append(contentsOf: types.map({.init(name: "types[]", value: $0.rawValue)}))
        }

        if let types = params.excludeTypes, !types.isEmpty {
            queryParameters.append(contentsOf: types.map({.init(name: "exclude_types[]", value: $0.rawValue)}))
        }

        return queryParameters
    }
}
