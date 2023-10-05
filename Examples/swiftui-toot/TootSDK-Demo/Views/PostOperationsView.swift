//
//  PostOperationsView.swift
//  SwiftUI-Toot
//
//  Created by dave on 26/11/22.
//

import SwiftUI
import TootSDK

struct PostOperationsView: View {
    @EnvironmentObject var tootManager: TootManager
    @Binding var postID: String?
    @Binding var path: NavigationPath
    
    @State var textToShow: String = ""
        
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(postID ?? "-")
                
                Text(textToShow)
                    .font(.body)
                    .padding()
                
                if let postID {
                    self.buttons(postID: postID)
                }
            }
        }
        .navigationTitle("Post Operations")
    }
    
    @ViewBuilder func buttons(postID: String) -> some View {
        Group {
            self.postButtons(postID: postID)
            self.favouriteButtons(postID: postID)
            self.boostButtons(postID: postID)
            self.bookmarkButtons(postID: postID)
            self.historySourceButtons(postID: postID)
        }
    }
    
    @ViewBuilder func postButtons(postID: String) -> some View {
        Group {
            ButtonView(text: "Get Post Details") {
                guard let post = try await tootManager.currentClient?.getPost(id: postID) else { return }
#if os(macOS)
				let renderer = AppKitAttribStringRenderer()
#else
				let renderer = UIKitAttribStringRenderer()
#endif
                let content = renderer.render(post)
                textToShow = content.attributedString.string
            }
            
            ButtonView(text: "Delete post") {
                let context = try await tootManager.currentClient?.deletePost(id: postID)
                self.postID = nil
                debugPrint(context ?? "")
                
                try await self.tootManager.currentClient?.data.refresh(.home)
                
                self.path.removeLast()
            }
            
            ButtonView(text: "Edit post (appends 🧡)") {
                guard let oldPost = try await tootManager.currentClient?.getPostSource(id: postID) else { return }
                
                
                let editParams = EditPostParams(post: "\(oldPost.text) 🧡",
                                                  spoilerText: oldPost.spoilerText)
                
                let context = try await tootManager.currentClient?.editPost(id: postID, editParams)
                debugPrint(context ?? "")
            }
            
            ButtonView(text: "Retrieve posts in context") {
                let context = try await tootManager.currentClient?.getContext(id: postID)
                debugPrint(context ?? "")
            }
        }
    }
    
    @ViewBuilder func favouriteButtons(postID: String) -> some View {
        Group {
            ButtonView(text: "Favourite") {
                let post = try await tootManager.currentClient?.favouritePost(id: postID)
                debugPrint(post ?? "")
            }
            
            ButtonView(text: "Unfavourite") {
                let post = try await tootManager.currentClient?.unfavouritePost(id: postID)
                debugPrint(post ?? "")
            }
            
            ButtonView(text: "Who favourited") {
                let boostAccounts = try await tootManager.currentClient.getAccountsFavourited(id: postID)
                debugPrint(boostAccounts)
            }
        }
    }
    
    @ViewBuilder func boostButtons(postID: String) -> some View {
        Group {
            ButtonView(text: "Boost") {
                let post = try await tootManager.currentClient.boostPost(id: postID)
                debugPrint(post)
            }
            
            ButtonView(text: "Unboost") {
                let post = try await tootManager.currentClient.unboostPost(id: postID)
                debugPrint(post)
            }
            
            ButtonView(text: "Who boosted") {
                let boostAccounts = try await tootManager.currentClient.getAccountsBoosted(id: postID)
                debugPrint(boostAccounts)
            }
        }
    }
    
    @ViewBuilder func bookmarkButtons(postID: String) -> some View {
        Group {
            ButtonView(text: "Bookmark") {
                let post = try await tootManager.currentClient.bookmarkPost(id: postID)
                debugPrint(post)
            }
            
            ButtonView(text: "Unbookmark") {
                let post = try await tootManager.currentClient.unbookmarkPost(id: postID)
                debugPrint(post)
            }
        }
    }
    
    @ViewBuilder func historySourceButtons(postID: String) -> some View {
        Group {
            
            
            ButtonView(text: "Get History of post") {
                let edits = try await tootManager.currentClient.getHistory(id: postID)
                debugPrint(edits)
            }
            
            ButtonView(text: "Get Post Source") {
                let postSource = try await tootManager.currentClient.getPostSource(id: postID)
                debugPrint(postSource)
            }
        }
    }
}


struct PostOperationsView_Previews: PreviewProvider {
    static var previews: some View {
        PostOperationsView(postID: .constant("test"), path: .constant(NavigationPath()))
    }
}
