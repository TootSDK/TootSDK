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
    
    @State var statuses: [Status] = []
    @State var name: String = ""
    
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(statuses, id: \.self) { status in
                Button {
                    self.path.append(status.id)
                } label: {
                    StatusView(status: status, attributed: true)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Feed")
            .navigationDestination(for: String.self) { value in
                PostOperationsView(postID: .constant(value), path: $path)
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
            
            // opt into status updates
            Task {
                for await updatedPosts in try await currentClient.data.stream(.timeLineHome) {
                    print("got a batch of posts")
                    statuses = updatedPosts
                }
            }
            
            refresh()
        }
        .refreshable {
            refresh()
        }
    }
    
    func refresh() {
        Task {
            try await tootManager.currentClient?.data.refresh(.timeLineHome)
            try await tootManager.currentClient?.data.refresh(.verifyCredentials)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
