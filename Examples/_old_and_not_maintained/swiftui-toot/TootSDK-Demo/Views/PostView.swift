//
//  PostView.swift
//  SwiftUI-Toot
//
//  Created by dave on 17/12/22.
//

import EmojiText
import NukeUI
import SwiftUI
import TootSDK

struct FeedPostView: View {
    @EnvironmentObject var tootManager: TootManager

    var post: FeedPost
    var attributed: Bool

    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            if post.tootPost.displayingRepost {
                HStack {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.3.trianglepath")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(width: 80)

                    EmojiText(
                        markdown: (post.tootPost.account.displayName ?? "") + " boosted",
                        emojis: post.tootPost.account.emojis.remoteEmojis()
                    )
                    .font(.caption.italic())

                    Spacer()
                }
            }

            HStack(alignment: .top) {
                LazyImage(url: URL(string: post.tootPost.displayPost.account.avatar))

                    .frame(width: 80, height: 80)
                    .onLongPressGesture {
                        self.path.append(post.tootPost.displayPost.account)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        EmojiText(
                            markdown: (post.tootPost.displayPost.account.displayName ?? ""),
                            emojis: post.tootPost.displayPost.account.emojis.remoteEmojis()
                        )
                        .font(.caption.bold())
                        Text(post.tootPost.displayPost.account.username ?? "?")
                            .font(.caption)

                        Spacer()
                    }

                    if attributed {
                        // Option 1: Use your own HTML renderer implementation. TootSDK has enriched the post by replacing all emoji :codes with <img> tags with an alt value equal to the :code and a data attribute  data-tootsdk-emoji hich can be used in CSS selectors

                        EmojiText(
                            markdown: post.markdown,
                            emojis: post.tootPost.emojis.remoteEmojis())
                    } else {
                        let renderer = UIKitAttribStringRenderer()
                        Text(renderer.render(post.tootPost.displayPost).string)
                    }
                }
            }
        }
    }
}
