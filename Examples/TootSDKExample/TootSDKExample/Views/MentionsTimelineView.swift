//
//  MentionsTimelineView.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import SwiftData
import SwiftUI
import TootSDK

struct MentionsTimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<DisplayPost> { $0.kind == "mention" },
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
                    Text("Loading mentions...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(posts) { post in
                    PostRow(post: post)
                }
            }
        }
        .task {
            await fetchMentions()
        }
        .refreshable {
            await fetchMentions()
        }
    }

    private func fetchMentions() async {
        do {
            let params = TootNotificationParams(types: [.mention])
            let page = try await client.getNotifications(params: params)
            let newPosts = page.result.compactMap { notif -> DisplayPost? in
                guard let post = notif.post else { return nil }
                let rendered = AttributedStringRenderer().render(html: post.content ?? "").plainString
                return DisplayPost(
                    kind: .mention,
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
            print("Failed to fetch mentions: \(error)")
        }
    }
}
