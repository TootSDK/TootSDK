// TootStream+Accounts.swift
//  Created by dave on 12/03/23.

import Foundation

/// A list of stream types which return `Account`
public enum AccountTootStreams: Hashable, Sendable {
    case verifyCredentials
    case account(id: String)
}

extension AccountTootStreams: TootStream {
    public typealias ResponseType = Account
}

// MARK: - Account stream creation
extension TootDataStream {
    /// Provides an async stream of updates for the given stream
    /// - Parameter stream: the stream type to update
    /// - Returns: async stream of values
    public func stream(_ stream: AccountTootStreams) throws -> AsyncStream<Account> {
        if let streamHolder = cachedStreams[stream] as? TootEndpointStream<AccountTootStreams> {
            return streamHolder.stream
        }

        let newHolder = TootEndpointStream(stream)

        switch stream {
        case .verifyCredentials:
            newHolder.refresh = { [weak self, weak newHolder] in
                if let item = try await self?.client.verifyCredentials() {
                    newHolder?.internalContinuation?.yield(item)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        case .account(let id):
            newHolder.refresh = { [weak self, weak newHolder] in
                if let item = try await self?.client.getAccount(by: id) {
                    newHolder?.internalContinuation?.yield(item)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        }
    }
}
