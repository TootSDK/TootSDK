//
//  PostView.swift
//  SwiftUI-Toot
//
//  Created by dave on 17/12/22.
//

import SwiftUI
import TootSDK

struct PostView: View {
    var post: Post
    var attributed: Bool

    @Binding var path: NavigationPath

    var displayPost: Post {
        return post.repost ?? self.post
    }
    
    var repost: Bool {
        return post.repost != nil
    }
    
    var body: some View {
        VStack {
            if repost {
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
                AsyncImage(url: URL(string: displayPost.account.avatar)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .onLongPressGesture {
                    self.path.append(displayPost.account)
                }

                VStack(spacing: 8) {
                    HStack {
                        Text(displayPost.account.displayName ?? "?")
                            .font(.caption.bold())
                        Text(displayPost.account.username ?? "?")
                            .font(.caption)
                        
                        Spacer()
                    }
                    
                    if attributed, let attributedText = displayPost.content?.attributedString {
                        Text(AttributedString(attributedText))
                    } else {
                        Text(displayPost.content?.plainContent ?? "")
                    }
                }
            }
        }
    }
}
