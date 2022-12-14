// Created by konstantin on 13/11/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A protocol that all stream types can adopt
public protocol TootStream {
    associatedtype ResponseType: Decodable
}

/// A list of stream types which return `[Status]`
public enum StatusTootStreams: Hashable {
    
    /// Provides your
    case timeLineHome
}

extension StatusTootStreams: TootStream {
    public typealias ResponseType = [Status]
}

/// A list of stream types which return `Account`
public enum AccountTootStreams: Hashable {
    case verifyCredentials
    case account(id: String)
}

extension AccountTootStreams: TootStream {
    public typealias ResponseType = Account
}

private protocol TootStreamHolder {
    associatedtype ReturnType: Decodable
    var stream: AsyncStream<ReturnType> {get}
    var internalContinuation: AsyncStream<ReturnType>.Continuation? {get set}
    var pageInfo: PagedInfo? {get set}
    var refresh: (() async throws -> Void)? {get}
}

private class TootEndpointStream<E: TootStream>: TootStreamHolder {
    public typealias ReturnType = E.ResponseType
    let endpoint: E
    init(_ endpoint: E) {
        self.endpoint = endpoint
    }
    
    lazy public var stream: AsyncStream<ReturnType> = AsyncStream<ReturnType> { continuation in
        self.internalContinuation = continuation
    }
    
    public var internalContinuation: AsyncStream<ReturnType>.Continuation?
    public var pageInfo: PagedInfo?
    public var refresh: (() async throws -> Void)?
}

// MARK: - TootDataStream

public actor TootDataStream {
    private var client: TootClient
    
    /// keeps track of active streams
    private var cachedStreams: [AnyHashable: any TootStreamHolder] = [:]
    
    // MARK: - Initialization
    public init(client: TootClient) {
        self.client = client
    }
    
    // MARK: - Updating data
    
    /// Reloads data in all currently active streams
    public func refreshStreams() async throws {
        print("refreshing \(self.cachedStreams.count) streams")
        for item in cachedStreams {
            do {
                try await item.value.refresh?()
            } catch {
                print("error refreshing stream: \(String(describing: error))")
            }
        }
    }
    
    /// Reloads data in the selected stream
    public func refresh(_ stream: StatusTootStreams) async throws {
        let streamHolder = cachedStreams[stream]
        try await streamHolder?.refresh?()
    }
    
    public func refresh(_ stream: AccountTootStreams) async throws {
        let streamHolder = cachedStreams[stream]
        try await streamHolder?.refresh?()
    }
    
}
 
// MARK: - Stream creation

extension TootDataStream {
    /// Provides an async stream of updates for the given stream
    /// - Parameter stream: the stream type to update
    /// - Returns: async stream of values
    public func stream(_ stream: StatusTootStreams, _ pageInfo: PagedInfo? = nil) throws -> AsyncStream<[Status]> {
        if let streamHolder = cachedStreams[stream] as? TootEndpointStream<StatusTootStreams> {
            return streamHolder.stream
        }
        
        let newHolder = TootEndpointStream(stream)
        
        switch stream {
        case .timeLineHome:
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getHomeTimeline(pageInfo) {
                    newHolder?.internalContinuation?.yield(items.result)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        }
    }
    
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
            newHolder.refresh = {[weak self, weak newHolder] in
                if let item = try await self?.client.verifyCredentials() {
                    newHolder?.internalContinuation?.yield(item)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        case .account(id: let id):
            newHolder.refresh = {[weak self, weak newHolder] in
                if let item = try await self?.client.getAccount(by: id) {
                    newHolder?.internalContinuation?.yield(item)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        }
    }
}
