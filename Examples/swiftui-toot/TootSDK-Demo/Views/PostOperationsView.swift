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
            self.statusButtons(postID: postID)
        }
    }
    
    @ViewBuilder func postButtons(postID: String) -> some View {
        Group {
            ButtonView(text: "Get Post Details") {
                textToShow = try await tootManager.currentClient?.getStatus(id: postID).content ?? "-"
            }
            
            ButtonView(text: "Delete post") {
                let context = try await tootManager.currentClient?.deleteStatus(id: postID)
                self.postID = nil
                debugPrint(context ?? "")
                
                try await self.tootManager.currentClient?.data.refresh(.timeLineHome)
                
                self.path.removeLast()
            }
            
            ButtonView(text: "Edit post (appends 🧡)") {
                guard let oldPost = try await tootManager.currentClient?.getStatusSource(id: postID) else { return }
                
                let editParams = EditStatusParams(post: "\(oldPost.content ?? "") 🧡",
                                                  spoilerText: oldPost.spoilerText,
                                                  sensitive: oldPost.sensitive,
                                                  mediaIds: nil,
                                                  poll: nil)
                
                let context = try await tootManager.currentClient?.editStatus(id: postID, editParams)
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
                let status = try await tootManager.currentClient?.favouriteStatus(id: postID)
                debugPrint(status ?? "")
            }
            
            ButtonView(text: "Unfavourite") {
                let status = try await tootManager.currentClient?.unfavouriteStatus(id: postID)
                debugPrint(status ?? "")
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
                let status = try await tootManager.currentClient.boostStatus(id: postID)
                debugPrint(status)
            }
            
            ButtonView(text: "Unboost") {
                let status = try await tootManager.currentClient.unboostStatus(id: postID)
                debugPrint(status)
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
                let status = try await tootManager.currentClient.bookmarkStatus(id: postID)
                debugPrint(status)
            }
            
            ButtonView(text: "Unbookmark") {
                let status = try await tootManager.currentClient.unbookmarkStatus(id: postID)
                debugPrint(status)
            }
        }
    }
    
    @ViewBuilder func statusButtons(postID: String) -> some View {
        Group {
            
            
            ButtonView(text: "Get History of post") {
                let edits = try await tootManager.currentClient.getHistory(id: postID)
                debugPrint(edits)
            }
            
            ButtonView(text: "Get Status Source") {
                let statusSource = try await tootManager.currentClient.getStatusSource(id: postID)
                debugPrint(statusSource)
            }
        }
    }
}


struct PostOperationsView_Previews: PreviewProvider {
    static var previews: some View {
        PostOperationsView(postID: .constant("test"), path: .constant(NavigationPath()))
    }
}
