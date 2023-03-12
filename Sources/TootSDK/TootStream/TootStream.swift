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

internal protocol TootStreamHolder {
    associatedtype ReturnType: Decodable
    var stream: AsyncStream<ReturnType> {get}
    var internalContinuation: AsyncStream<ReturnType>.Continuation? {get set}
    var pageInfo: PagedInfo? {get set}
    var refresh: (() async throws -> Void)? {get}
}

internal class TootEndpointStream<E: TootStream>: TootStreamHolder {
    internal typealias ReturnType = E.ResponseType
    let endpoint: E
    
    internal init(_ endpoint: E) {
        self.endpoint = endpoint
    }
    
    lazy internal var stream: AsyncStream<ReturnType> = AsyncStream<ReturnType> { continuation in
        self.internalContinuation = continuation
    }
    
    internal var internalContinuation: AsyncStream<ReturnType>.Continuation?
    internal var pageInfo: PagedInfo?
    internal var refresh: (() async throws -> Void)?
}

// MARK: - TootDataStream

/// Provides a holder that returns streams of AsyncSequence data that can be refreshed, posts, account data etc
public actor TootDataStream {
    internal nonisolated let client: TootClient
    
    /// keeps track of active streams
    internal var cachedStreams: [AnyHashable: any TootStreamHolder] = [:]
    
    // MARK: - Initialization
    
    /// Initialises a TootStream with a given client, it is assumed the client is authorized already
    /// - Parameter client:TootClient to provide data streams for
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
        
    /// Reloads data in the selected stream for account toot streams
    public func refresh(_ stream: AccountTootStreams) async throws {
        let streamHolder = cachedStreams[stream]
        try await streamHolder?.refresh?()
    }
    
}
