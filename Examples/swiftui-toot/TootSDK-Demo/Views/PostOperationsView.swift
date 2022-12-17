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
                
                self.buttons()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Post Operations")
    }
    
    @ViewBuilder func buttons() -> some View {
        if let postID {
            Group {
                self.createButton(text: "Get Post Details") {
                    textToShow = try await tootManager.currentClient?.getStatus(id: postID)?.content ?? "-"
                }
                
                self.createButton(text: "Delete post") {
                    if let context = try await tootManager.currentClient?.deleteStatus(id: postID) {
                        self.postID = nil
                        debugPrint(context)
                    }
                    
                    try await self.tootManager.currentClient?.data.refresh(.timeLineHome)
                    
                    self.path.removeLast()
                }
                
                self.createButton(text: "Edit post (appends 🧡)") {
                    guard let oldPost = try await tootManager.currentClient?.getStatus(id: postID) else {
                        print("Unknown postID \(postID)")
                        return
                    }
                    let editParams = EditStatusParams(status: "\(oldPost.content ?? "") 🧡", spoilerText: oldPost.spoilerText, sensitive: oldPost.sensitive, mediaIds: nil, poll: nil)
                    if let context = try await tootManager.currentClient?.editStatus(id: postID, editParams) {
                        debugPrint(context)
                    }
                    
                }
                
                self.createButton(text: "Retrieve posts in context") {
                    if let context = try await tootManager.currentClient?.getContext(id: postID) {
                        debugPrint(context)
                    }
                }
                
                self.createButton(text: "Favourite") {
                    if let status = try await tootManager.currentClient?.favouriteStatus(id: postID) {
                        debugPrint(status)
                    }
                }
                
                self.createButton(text: "Unfavourite") {
                    if let status = try await tootManager.currentClient?.unfavouriteStatus(id: postID) {
                        debugPrint(status)
                    }
                }
                
                self.createButton(text: "Boost") {
                    if let status = try await tootManager.currentClient?.boostStatus(id: postID) {
                        debugPrint(status)
                    }
                }
                
                self.createButton(text: "Unboost") {
                    if let status = try await tootManager.currentClient?.unboostStatus(id: postID) {
                        debugPrint(status)
                    }
                }
                
                self.createButton(text: "Bookmark") {
                    if let status = try await tootManager.currentClient?.bookmarkStatus(id: postID) {
                        debugPrint(status)
                    }
                }
                
                self.createButton(text: "Unbookmark") {
                    if let status = try await tootManager.currentClient?.unbookmarkStatus(id: postID) {
                        debugPrint(status)
                    }
                }
            }
            
            Group {
                self.createButton(text: "Who boosted") {
                    if let boostAccounts = try await tootManager.currentClient?.getAccountsBoosted(id: postID) {
                        debugPrint(boostAccounts)
                    }
                }
                                
                self.createButton(text: "Who favourited") {
                    if let boostAccounts = try await tootManager.currentClient?.getAccountsFavourited(id: postID) {
                        debugPrint(boostAccounts)
                    }
                }
                
                self.createButton(text: "Get History of post") {
                    if let edits = try await tootManager.currentClient?.getHistory(id: postID) {
                        debugPrint(edits)
                    }
                }
                
                self.createButton(text: "Get Status Source") {
                    if let statusSource = try await tootManager.currentClient?.getStatusSource(id: postID) {
                        debugPrint(statusSource)
                    }
                }
            }
            
                        
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder func createButton(text: String, action: @escaping () async throws -> Void) -> some View {
        Button {
            Task {
                try await action()
            }
        } label: {
            Text(text)
                .frame(height: 44)
        }
        
    }
    
}

struct PostOperationsView_Previews: PreviewProvider {
    static var previews: some View {
        PostOperationsView(postID: .constant("test"), path: .constant(NavigationPath()))
    }
}
