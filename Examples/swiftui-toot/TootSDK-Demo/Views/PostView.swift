//
//  PostView.swift
//  SwiftUI-Toot
//
//  Created by dave on 17/12/22.
//

import SwiftUI
import TootSDK
import RichText

struct FeedPostView: View {
    @EnvironmentObject var tootManager: TootManager
    
    var post: FeedPost
    var attributed: Bool
    
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            if post.post.displayingRepost {
                HStack {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.3.trianglepath")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(width: 80)
                    
                    Text((post.post.account.displayName ?? "") + " boosted")
                        .font(.caption.italic())
                    
                    Spacer()
                }
            }
            
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: post.post.displayPost.account.avatar)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .onLongPressGesture {
                    self.path.append(post.post.displayPost.account)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text(post.post.displayPost.account.displayName ?? "?")
                            .font(.caption.bold())
                        Text(post.post.displayPost.account.username ?? "?")
                            .font(.caption)
                        
                        Spacer()
                    }
                    
                    if attributed {
                        // Option 1: Use your own HTML renderer implementation. TootSDK has enriched the post by replacing all emoji :codes with <img> tags with an alt value equal to the :code and a data attribute  data-tootsdk-emoji hich can be used in CSS selectors

                        HTMLView(html: post.html)
                        
                        // Option 2: Simplified NSAttributedString which respects system font styles but (for the moment) does not support images.
                        // Text(AttributedString(renderer.render(post.displayPost).attributedString))
                        
                        // Option 2.1: The plain text representation of the simplified NSAttributedString includes emoji :codes
                        // Text(AttributedString(renderer.render(post.displayPost).attributedString.string))
                        
                        // Option 3: The HTML as an instance of NSAttributedString with default system behaviour a la NSAttributedString.DocumentType.html
                        // Text(AttributedString(renderer.render(post.displayPost).systemAttributedString))
                    } else {
                        let renderer = tootManager.currentClient.getRenderer()
                        Text(renderer.render(post.post.displayPost).string)
                    }
                }
            }
        }
    }
}
