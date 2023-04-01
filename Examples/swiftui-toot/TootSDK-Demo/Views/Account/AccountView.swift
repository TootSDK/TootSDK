//
//  AccountView.swift
//  SwiftUI-Toot
//
//  Created by dave on 21/12/22.
//

import SwiftUI
import TootSDK
import NukeUI
import EmojiText

struct AccountView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @State var posts: [FeedPost] = []
    @State var relationship: Relationship? = nil
    @State var showingReblogs: Bool = false
    @State var notify: Bool = false
    
    var account: Account
    
    var body: some View {
        List {
            Section(header: header()) {
                ForEach(posts, id: \.self) { post in
                    FeedPostView(post: post, attributed: true, path: .constant(NavigationPath()))
                }
            }
        }
        .navigationTitle("Account")
        .onAppear {
            Task {
                self.relationship = try await self.tootManager.currentClient.getRelationships(by: [account.id]).first
                let posts = try await self.tootManager.currentClient.getAccountPosts(for: account.id).result
                await updatePosts(posts)
            }
        }
    }
    
    @MainActor func updatePosts(_ posts: [Post]) async {
        let renderer = UIKitAttribStringRenderer()

        let newPosts = posts.map { post in

            let html = renderer.render(post.displayPost).wrappedValue
            let markdown = TootHTML.extractAsPlainText(html: post.displayPost.content) ?? ""
            
            return FeedPost(html: html, markdown: markdown, tootPost: post)
        }
        
        self.posts = newPosts
    }
    
    @ViewBuilder func header() -> some View {
        VStack(alignment: .leading) {
            HStack {
                LazyImage(url: URL(string: account.avatar))
                    .frame(width: 80, height: 80, alignment: .topLeading)
                
                Spacer()
            }
                            
            AccountItemView(description: "displayName") {
                EmojiText(markdown: account.displayName ?? "",
                          emojis: account.emojis.remoteEmojis())
            }
            
            AccountItemView(description: "username", value: account.username)
            
            if let relationship {
                RelationshipView(relationship: relationship)
            }
            
            Text("Recent Posts")
                .font(.caption)
        }
    }
    
}

