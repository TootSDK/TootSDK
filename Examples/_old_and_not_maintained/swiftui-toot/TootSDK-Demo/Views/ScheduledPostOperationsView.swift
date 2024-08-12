//  ScheduledPostOperationsView.swift
//  Created by dave on 7/12/22.

import SwiftUI
import TootSDK

struct ScheduledPostOperationsView: View {
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
        }
        .navigationTitle("Scheduled Post Operations")
    }

    @ViewBuilder func buttons() -> some View {
        if let postID {
            Group {
                ButtonView(text: "Get Scheduled Post Details") {
                    textToShow = try await tootManager.currentClient?.getScheduledPost(id: postID)?.params.text ?? "-"
                }

                ButtonView(text: "Delete scheduled post") {
                    if let _ = try await tootManager.currentClient?.deleteScheduledPost(id: postID) {
                        self.postID = nil
                        self.path.removeLast()
                    }
                }

                ButtonView(text: "Update post date (to now + 10 mins)") {
                    if let oldPost = try await tootManager.currentClient?.getScheduledPost(id: postID) {
                        var params = oldPost.params
                        params.scheduledAt = Date().addingTimeInterval(TimeInterval(10.0 * 60.0))

                        if let context = try await tootManager.currentClient?.updateScheduledPostDate(id: postID, params) {
                            debugPrint(context)
                        }
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct ScheduledPostOperationsView_Previews: PreviewProvider {
    static var previews: some View {
        PostOperationsView(postID: .constant("test"), path: .constant(NavigationPath()))
    }
}
