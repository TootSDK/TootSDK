//
//  FeedView.swift
//  TootSDK-Demo
//
//  Created by dave on 6/11/22.
//

import SwiftUI
import TootSDK

struct FeedView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @State var posts: [Post] = []
    @State var name: String = ""
    
    @State var path: NavigationPath = NavigationPath()
    
    @State var loading: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            List(posts, id: \.self) { post in
                Button {
                    self.path.append(post.displayPost.id)
                } label: {
                    PostView(post: post, attributed: true, path: $path)
                        .background(.background.opacity(0.001)) // Enables the whole row to be pressed
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Feed")
            .navigationDestination(for: String.self) { value in
                PostOperationsView(postID: .constant(value), path: $path)
            }
            .navigationDestination(for: Account.self) { account in
                AccountView(account: account)
            }
        }
        .task {
            // Only opt in, if we have data loaded
            guard let currentClient = tootManager.currentClient else { return }
            
            // opt into account updates
            Task {
                for await account in try await currentClient.data.stream(.verifyCredentials) {
                    print("got account update")
                    name = account.displayName ?? "-"
                }
            }
            
            // opt into posts updates
            Task {
                for await updatedPosts in try await currentClient.data.stream(.timeLineHome) {
                    print("got a batch of posts")
                    posts = updatedPosts
                }
            }
            
            // Reset data if the client changes (user has signed in/out etc
            Task {
                for await _ in tootManager.$currentClient.values {
                    posts = []
                    name = ""
                }
            }
            
            // Refresh our data
            refresh()
        }
        .refreshable {
            refresh()
        }
        .overlay {
            if loading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    ProgressView()
                }
                
            }
        }
    }
    
    func refresh() {
        Task {
            loading = true
            try await tootManager.currentClient?.data.refresh(.timeLineHome)
            try await tootManager.currentClient?.data.refresh(.verifyCredentials)
            loading = false
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
