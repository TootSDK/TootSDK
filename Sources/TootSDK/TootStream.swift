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
public enum PostTootStreams: Hashable, Sendable {
    
    /// A stream of the user's home timeline
    case timeLineHome
    
    /// A stream of the user's local timeline
    case timeLineLocal(onlyMedia: Bool?)
    
    /// A stream of the user's federated timeline
    case timeLineFederated(onlyMedia: Bool?)
    
    /// A stream of a hashtag timeline with the given options
    case timeLineHashtag(tag: String, anyTags: [String]?, allTags: [String]?, noneTags: [String]?, onlyMedia: Bool?, locality: TimelineLocality?)

    /// A stream of the user's favourite posts
    case favourites
    
    /// A stream of the user's bookmarked posts
    case bookmarks
}

extension PostTootStreams: TootStream {
    public typealias ResponseType = [Post]
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
    public func refresh(_ stream: PostTootStreams) async throws {
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
    /// - Parameter stream: the stream type to update
    /// - Returns: async stream of values
    public func stream(_ stream: PostTootStreams, _ pageInfo: PagedInfo? = nil) throws -> AsyncStream<[Post]> { // swiftlint:disable:this cyclomatic_complexity function_body_length
        if let streamHolder = cachedStreams[stream] as? TootEndpointStream<PostTootStreams> {
            return streamHolder.stream
        }
        
        let newHolder = TootEndpointStream(stream)
        newHolder.pageInfo = pageInfo
        
        switch stream {
        case .timeLineHome:
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getHomeTimeline(newHolder?.pageInfo) {
                    newHolder?.internalContinuation?.yield(items.result)
                                        
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        case .timeLineLocal(let onlyMedia):
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getLocalTimeline(newHolder?.pageInfo, onlyMedia: onlyMedia) {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        case .timeLineFederated(let onlyMedia):
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getFederatedTimeline(newHolder?.pageInfo, onlyMedia: onlyMedia) {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[stream] = newHolder
            return newHolder.stream
        case .timeLineHashtag(let tag, let anyTags, let allTags, let noneTags, let onlyMedia, let locality):
            newHolder.refresh = {[weak self, weak newHolder] in
                if let items = try await self?.client.getHashtagTimeline(tag: tag, anyTags: anyTags, allTags: allTags, noneTags: noneTags, newHolder?.pageInfo, onlyMedia: onlyMedia, locality: locality) {
                    newHolder?.internalContinuation?.yield(items.result)
                    
                    // Update PagedInfo
                    let minId = items.result.first?.id
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
            self.cachedStreams[stream] = newHolder
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
            self.cachedStreams[stream] = newHolder
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
