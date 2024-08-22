// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// Extensions to add support for async methods on `URLSession`
// Similar to https://www.iamkonstantin.eu/post/2022/06/18/code-snippet-urlsession.datafor-request-for-ios14/ but here also with support for `FoundationNetworking` when building on Linux

extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(for: URLRequest(url: url))
    }
}

extension URLSession {
    private class TaskHandle: @unchecked Sendable {
        weak var dataTask: URLSessionDataTask?
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let taskHandle = TaskHandle()

        try Task.checkCancellation()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                taskHandle.dataTask = self.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }

                taskHandle.dataTask?.resume()
            }
        } onCancel: {
            taskHandle.dataTask?.cancel()
        }

    }
}
