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
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                if let error = error {
                    return continuation.resume(throwing: error)
                }

                guard let data = data, let response = response else {
                    return continuation.resume(throwing: URLError(.badServerResponse))
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    return continuation.resume(throwing: error)
                }

                guard let data = data, let response = response else {
                    return continuation.resume(throwing: URLError(.badServerResponse))
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
