// Created by konstantin on 13/11/2022.
// Copyright (c) 2022. All rights reserved.



import SwiftUI
import TootSDK

struct TestView: View {
    @StateObject var tootStreams = TootStreams(client: .init(session: .shared, instanceURL: URL(string: "<>")!, accessToken: "<>"))
    
    @State var name: String = ""
    @State var posts: [Status] = []
    
    var body: some View {
        VStack {
            Text(name)
            HStack {
                Button("Stop", action: {
                    Task {
                        await tootStreams.stop()
                    }
                })
                Spacer()
                Button("Start", action: {
                    Task {
                        await tootStreams.start()
                    }
                })
            }
            
            List(posts, id: \.self) {row in
                Text(row.content ?? "-")
            }
        }
            .task {
                // opt into account updates
                Task {
                    for await account in try await tootStreams.stream(.verifyCredentials) {
                        print("got account update")
                        name = account.displayName ?? "-"
                    }
                }
                
                // opt into status updates
                Task {
                    for await updatedPosts in try await tootStreams.stream(.timeLineHome) {
                        print("got a batch of posts")
                        posts = updatedPosts
                    }
                }
                
                Task {
                    print("starting streams...")
                    await tootStreams.start()
                }
            }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
