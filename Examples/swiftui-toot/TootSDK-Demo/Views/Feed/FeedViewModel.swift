//  FeedViewModel.swift
//  Created by dave on 23/01/23.

import Foundation
import Combine
import TootSDK
import SwiftUI

struct FeedPost: Hashable {
    var html: String
    var markdown: String
    var tootPost: Post
}

actor FeedViewModel: ObservableObject {
    @MainActor @Published var feedPosts: [FeedPost] = []
    @MainActor @Published var loading: Bool = false
    @MainActor @Published var name: String = ""
    
    @MainActor private var tootManager: TootManager?
    
    // MARK: - Published var updates
    @MainActor private func setPosts(_ feedPosts: [FeedPost]) {
        self.feedPosts = feedPosts
    }
    
    @MainActor private func setLoading(_ loading: Bool) {
        self.loading = loading
    }
    
    @MainActor private func setName(_ name: String) {
        self.name = name
    }
}

// MARK: - Public methods
extension FeedViewModel {
    
    public func refresh() async throws {
        await setLoading(true)
        try await tootManager?.currentClient?.data.refresh(.timeLineHome)
        try await tootManager?.currentClient?.data.refresh(.verifyCredentials)
        await setLoading(false)
    }
    
    @MainActor public func setManager(_ tootManager: TootManager) async {
        self.tootManager = tootManager
        await self.setBindings()
    }
    
}

// MARK: - Bindings
extension FeedViewModel {
    private func setBindings() async {
        guard let tootManager = await self.tootManager else { return }
        
        Task {
            for await updatedPosts in try await tootManager.currentClient.data.stream(.timeLineHome) {
                let renderer = UIKitAttribStringRenderer()
                
                let feedPosts = updatedPosts.map { post in

                    let html = renderer.render(post.displayPost).wrappedValue
                    let markdown = TootHTML.stripHTMLFormatting(html: post.displayPost.content) ?? ""
                    
                    return FeedPost(html: html, markdown: markdown, tootPost: post)
                }
                
                await setPosts(feedPosts)
            }
        }
        
        // Reset data if the client changes (user has signed in/out etc
        Task {
            for await _ in tootManager.$currentClient.values {
                await setPosts([])
                await setName("")
            }
        }
        
        // opt into account updates
        Task {
            for await account in try await  tootManager.currentClient.data.stream(.verifyCredentials) {
                print("got account update")
                await self.setName(account.displayName ?? "-")
            }
        }

    }
}
