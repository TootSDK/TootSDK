//
//  HomeTimelineView.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import SwiftData
import SwiftUI
import TootSDK

struct HomeTimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<DisplayPost> { $0.kind == "home" },
        sort: \DisplayPost.createdAt,
        order: .reverse
    )
    private var posts: [DisplayPost]

    let client: TootClient

    var body: some View {
        Group {
            if posts.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Loading posts...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(posts) { post in
                    PostRow(post: post)
                }
            }
        }
        .task {
            await fetchPosts()
        }
        .refreshable {
            await fetchPosts()
        }
    }

    private func fetchPosts() async {
        do {
            let timeline = try await client.getTimeline(.home)
            let newPosts = timeline.result.compactMap { post -> DisplayPost? in
                let rendered = AttributedStringRenderer().render(html: post.content ?? "").plainString
                return DisplayPost(
                    kind: .home,
                    id: post.id,
                    authorName: post.account.displayName ?? post.account.username ?? "",
                    authorUsername: post.account.acct,
                    content: rendered,
                    createdAt: post.createdAt,
                    url: post.url ?? post.uri
                )
            }
            for post in posts {
                modelContext.delete(post)
            }
            for post in newPosts {
                modelContext.insert(post)
            }
            try? modelContext.save()
        } catch {
            print("Failed to fetch home timeline: \(error)")
        }
    }
}
