//
//  MakePostView.swift
//  TootSDK-Demo
//
//  Created by dave on 6/11/22.
//

import SwiftUI
import TootSDK

enum MakePostDestination {
    case postOperations
    case scheduledPost
}

struct MakePostView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @State var post: String = ""
    @State var loading: Bool = false
    @State var lastPostID: String?
    @State var lastPostScheduledPost: Bool = false
    @State var scheduledPost: Bool = false
    
    @State private var path = NavigationPath()
        
    @State var visibility: Post.Visibility = .public {
        didSet {
            print(visibility)
        }
    }
    
    @FocusState private var postIsFocused: Bool
    
    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Picker(selection: $visibility, label: Text("Position")) {
                    ForEach(Post.Visibility.allCases, id: \.self) { visibility in
                        Text(visibility.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Scheduled", isOn: $scheduledPost)
                
                TextField("write your post", text: $post, axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                    .focused($postIsFocused)
                
                Button {
                    Task {
                        self.loading =  true
                        
                        do {
                            try await makePost()
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        self.postIsFocused = false
                        
                        self.loading = false
                    }
                } label: {
                    Text("Post")
                }
                
            }
            .navigationDestination(for: MakePostDestination.self) { value in
                switch value {
                case .postOperations:
                    PostOperationsView(postID: $lastPostID, path: $path)
                case .scheduledPost:
                    ScheduledPostOperationsView(postID: $lastPostID, path: $path)
                }
            }
            .navigationTitle("Make Post")
            .overlay {
                if self.loading {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                        
                        ProgressView()
                    }
                }
            }
            .toolbar {
                if let _ = lastPostID {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if !lastPostScheduledPost {
                                path.append(MakePostDestination.postOperations)
                            } else {
                                path.append(MakePostDestination.scheduledPost)
                            }
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
        }
    }
    
    func makePost() async throws {
        if !self.scheduledPost {
            lastPostID = try await self.makeRegularPost()
            lastPostScheduledPost = false
        } else {
            lastPostID = try await self.makePostScheduled()
            lastPostScheduledPost = true
        }
        
        self.post = ""
    }
    
    func makeRegularPost() async throws -> String? {
        let params = PostParams.init(status: post, mediaIds: [], visibility: visibility)
        return try await tootManager.currentClient?.publishPost(params).id
    }
    
    func makePostScheduled() async throws -> String? {
        let date = Date().addingTimeInterval(TimeInterval(10.0 * 60.0)) // Add 10 minutes to it
        let scheduledStatusParams = ScheduledStatusParams(text: post, mediaIds: [], visibility: visibility, scheduledAt: date)
        return try await tootManager.currentClient?.scheduleStatus(scheduledStatusParams).id
    }
    
}

struct MakePostView_Previews: PreviewProvider {
    static var previews: some View {
        MakePostView()
    }
}
