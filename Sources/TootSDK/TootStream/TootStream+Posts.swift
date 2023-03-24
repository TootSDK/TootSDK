//  TootStream+Posts.swift
//  Created by dave on 12/03/23.

import Foundation

extension Timeline: TootStream {
    public typealias ResponseType = [Post]
}

// MARK: - Post stream creation
extension TootDataStream {
    
    /// Provides an async stream of updates for the given stream
    /// - Parameters:
    ///   - timeline: the type of post stream to update
    ///   - pageInfo: PagedInfo object for max/min/since ids
    ///   - query: the timeline query to apply to the stream
    /// - Returns: async stream of Post values
    public func stream(_ timeline: Timeline, _ pageInfo: PagedInfo? = nil) throws -> AsyncStream<[Post]> {
        
        if let streamHolder = cachedStreams[timeline] as? TootEndpointStream<Timeline> {
            return streamHolder.stream
        }
        
        let newHolder = TootEndpointStream(timeline)
        newHolder.pageInfo = pageInfo
        
        newHolder.refresh = {[weak self, weak newHolder] in
            if let items = try await self?.client.getTimeline(timeline, pageInfo: newHolder?.pageInfo) {
                newHolder?.internalContinuation?.yield(items.result)
                
                // Update `PagedInfo` only if a new `minId` is available.
                if let minId = items.info.minId {
                    newHolder?.pageInfo = PagedInfo(minId: minId)
                }
            }
        }
        self.cachedStreams[timeline] = newHolder
        return newHolder.stream
    }
}

extension TootDataStream {
    /// Reloads data in the selected stream for post toot streams
    public func refresh(_ timeline: Timeline) async throws {
        let streamHolder = cachedStreams[timeline]
        try await streamHolder?.refresh?()
    }
}
