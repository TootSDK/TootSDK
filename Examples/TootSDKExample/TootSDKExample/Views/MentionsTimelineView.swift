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

    private static let blockQuoteStyle: BlockQuoteStyle = {
        var marks = AttributeContainer()
        marks.swiftUI.font = .system(size: 32, weight: .bold)
        marks.swiftUI.foregroundColor = .green

        var body = AttributeContainer()
        body.swiftUI.font = .body

        return BlockQuoteStyle(
            locale: Locale(identifier: "en_US"),
            markAttributes: marks,
            contentAttributes: body
        )
    }()

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
                    MentionRow(post: post, blockQuoteStyle: Self.blockQuoteStyle)
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
                return DisplayPost(
                    kind: .mention,
                    id: post.id,
                    authorName: post.account.displayName ?? post.account.username ?? "",
                    authorUsername: post.account.acct,
                    content: post.content ?? "",
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

private struct MentionRow: View {
    let post: DisplayPost
    let blockQuoteStyle: BlockQuoteStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.authorName)
                .font(.headline)
            Text(AttributedStringRenderer.shared.render(html: post.content, blockQuoteStyle: blockQuoteStyle).attributedString)
                .lineLimit(5)
            Text(post.createdAt, style: .relative)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
