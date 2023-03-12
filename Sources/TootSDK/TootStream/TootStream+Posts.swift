//  TootStream+Posts.swift
//  Created by dave on 12/03/23.

import Foundation

/// A list of stream types which return `[Post]`
public enum PostTootStreamType: Hashable, Sendable {
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

// MARK: - Post stream creation
extension TootDataStream {
    
    /// Provides an async stream of updates for the given stream
    /// - Parameters:
    ///   - timeline: the type of post stream to updarte
    ///   - pageInfo: PagedInfo object for max/min/since ids
    ///   - query: the timeline query to apply to the stream
    /// - Returns: async stream of Post values
    public func stream(_ timeline: PostTootStreamType, _ pageInfo: PagedInfo? = nil, _ query: (any TimelineQuery)? = nil) throws -> AsyncStream<[Post]> { // swiftlint:disable:this cyclomatic_complexity function_body_length
        let postStream = try createPostStream(timeline: timeline, query: query)

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
                   let items = try await self?.client.getLocalTimeline(query, newHolder?.pageInfo) {
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
                   let items = try await self?.client.getFederatedTimeline(query, newHolder?.pageInfo) {
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
    
    internal func createPostStream(timeline: PostTootStreamType, query: (any TimelineQuery)? = nil) throws -> PostStream {
        // Use default query type if not provided
        let query = query ?? timeline.defaultQuery()
        
        // Check parameter is correct
        switch timeline {
        case .timeLineLocal:
            guard let _ = query as? LocalTimelineQuery else { throw TootSDKError.invalidQueryType(expectedQuery: "LocalTimelineQuery") }
        case .timeLineFederated:
            guard let _ = query as? FederatedTimelineQuery else { throw TootSDKError.invalidQueryType(expectedQuery: "FederatedTimelineQuery") }
        default:
            break
            // Do nothing
        }
        
        let postStream = PostStream(timeline: timeline, query: query)
        return postStream
    }
    
}

extension TootDataStream {
    /// Reloads data in the selected stream for post toot streams
    public func refresh(_ timeline: PostTootStreamType, query: (any TimelineQuery)? = nil) async throws {
        let postStream = try createPostStream(timeline: timeline, query: query)
        let streamHolder = cachedStreams[postStream]
        try await streamHolder?.refresh?()
    }
}
