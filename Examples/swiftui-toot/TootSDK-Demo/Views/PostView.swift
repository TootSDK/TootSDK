//
//  PostView.swift
//  SwiftUI-Toot
//
//  Created by dave on 17/12/22.
//

import SwiftUI
import TootSDK

struct PostView: View {
    var renderer: TootAttribStringRenderer
    var post: Post
    var attributed: Bool

    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            if post.displayingRepost {
                HStack {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.3.trianglepath")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(width: 80)
                    
                    Text((post.account.displayName ?? "") + " boosted")
                        .font(.caption.italic())
                    
                    Spacer()
                }
            }
            
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: post.displayPost.account.avatar)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .onLongPressGesture {
                    self.path.append(post.displayPost.account)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text(post.displayPost.account.displayName ?? "?")
                            .font(.caption.bold())
                        Text(post.displayPost.account.username ?? "?")
                            .font(.caption)
                        
                        Spacer()
                    }
                    
                    if attributed {
                        Text(AttributedString(renderer.render(post.displayPost).attributedString))
                    } else {
                        Text(renderer.render(post.displayPost).string)
                    }
                }
            }
        }
    }
}
