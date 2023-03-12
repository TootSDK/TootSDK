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

/// A list of stream types which return `[Post]`
public enum PostTootStreamType: Hashable, Sendable {
    public typealias ResponseType = [Post]
    
    /// A stream of the user's home timeline
    case timeLineHome
    
    /// A stream of the user's local timeline
    case timeLineLocal
    
    /// A stream of the user's federated timeline
    case timeLineFederated
    
    /// A stream of the user's favourite posts
    case favourites
    
    /// A stream of the user's bookmarked posts
    case bookmarks
    
    func defaultQuery() -> (any TimelineQuery)? {
        switch self {
        case .timeLineLocal:
            return LocalTimelineQuery()
        case .timeLineFederated:
            return FederatedTimelineQuery()
        case .timeLineHome, .bookmarks, .favourites:
            return nil
        }
    }
}

public struct PostStream: TootStream, Hashable {
    public typealias ResponseType = [Post]
    
    var timeline: PostTootStreamType
    var query: (any TimelineQuery)?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(timeline)
        
        if let values = self.query?.getQueryItems() {
            hasher.combine(values)
        }
    }

    public static func == (lhs: PostStream, rhs: PostStream) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

/// A list of stream types which return `Account`
public enum AccountTootStreams: Hashable, Sendable {
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
    private nonisolated let client: TootClient
    
    /// keeps track of active streams
    private var cachedStreams: [AnyHashable: any TootStreamHolder] = [:]
    
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
    
    /// Reloads data in the selected stream for post toot straems
    public func refresh(_ stream: PostTootStreamType) async throws {
        let streamHolder = cachedStreams[stream]
        try await streamHolder?.refresh?()
    }
    
    /// Reloads data in the selected stream for account toot streams
    public func refresh(_ stream: AccountTootStreams) async throws {
        let streamHolder = cachedStreams[stream]
        try await streamHolder?.refresh?()
    }
    
}

// MARK: - Stream creation


extension TootDataStream {
    
    /// Provides an async stream of updates for the given stream
    /// - Parameters:
    ///   - timeline: the type of post stream to updarte
    ///   - pageInfo: PagedInfo object for max/min/since ids
    ///   - query: the timeline query to apply to the stream
    /// - Returns: async stream of Post values
    public func stream(_ timeline: PostTootStreamType, _ pageInfo: PagedInfo? = nil, _ query: (any TimelineQuery)? = nil) throws -> AsyncStream<[Post]> {
        // Use default query type if not provided
        let query = query ?? timeline.defaultQuery()
                
        // Check parameter is correct
        switch timeline {
        case .timeLineLocal:
            guard let _ = query as? LocalTimelineQuery else { throw TootSDKError.invalidQueryType(expectedQuery: "LocalTimelineQuery") }
        case .timeLineFederated:
            guard let _ = query as? FederatedTimelineQuery else { throw TootSDKError.invalidQueryType(expectedQuery: "FederatedTimelineQuery") }
        default:
            print("blah")
        }
        
        let postStream = PostStream(timeline: timeline, query: query)
        
        if let streamHolder = cachedStreams[postStream] as? TootEndpointStream<PostStream> {
            return streamHolder.stream
        }
        
        let newHolder = TootEndpointStream(postStream)
        newHolder.pageInfo = pageInfo
        
        switch timeline {
        case .timeLineHome:
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getHomeTimeline(newHolder?.pageInfo) {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[postStream] = newHolder
            return newHolder.stream
        case .timeLineLocal:
            newHolder.refresh = {[weak self, weak newHolder] in
                if let query = query as? LocalTimelineQuery,
                   let items = try await self?.client.getLocalTimeline(query, newHolder?.pageInfo)
                {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[postStream] = newHolder
            return newHolder.stream
        case .timeLineFederated:
            newHolder.refresh = {[weak self, weak newHolder] in
                if let query = query as? FederatedTimelineQuery,
                   let items = try await self?.client.getFederatedTimeline(query, newHolder?.pageInfo)
                {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[postStream] = newHolder
            return newHolder.stream
        case .favourites:
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getFavorites(pageInfo) {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[postStream] = newHolder
            return newHolder.stream
            
        case .bookmarks:
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getBookmarks(pageInfo) {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[postStream] = newHolder
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
