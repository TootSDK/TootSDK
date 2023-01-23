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
    @StateObject var viewModel = FeedViewModel()
    
    @State var name: String = ""
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(viewModel.feedPosts, id: \.self) { feedPost in
                Button {
                    self.path.append(feedPost.post.displayPost.id)
                } label: {
                    FeedPostView(post: feedPost, attributed: true, path: $path)
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
            await viewModel.setManager(tootManager)
            try? await viewModel.refresh()
        }
        .refreshable {
            try? await viewModel.refresh()
        }
        .overlay {
            if viewModel.loading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    ProgressView()
                }
                
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
