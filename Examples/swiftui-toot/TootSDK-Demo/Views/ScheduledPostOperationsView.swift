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
                self.createButton(text: "Get Scheduled Post Details") {
                    textToShow = try await tootManager.currentClient?.getScheduledStatus(id: postID)?.params.text ?? "-"
                }
                
                self.createButton(text: "Delete scheduled post") {
                    if let _ = try await tootManager.currentClient?.deleteScheduledStatus(id: postID) {
                        self.postID = nil
                        self.path.removeLast()
                    }
                }
                
                self.createButton(text: "Update post date (to now + 10 mins)") {
                    if let oldStatus = try await tootManager.currentClient?.getScheduledStatus(id: postID) {
                        var params = oldStatus.params
                        params.scheduledAt = Date().addingTimeInterval(TimeInterval(10.0 * 60.0))
                        
                        if let context = try await tootManager.currentClient?.updateScheduledStatusDate(id: postID, params) {
                            debugPrint(context)
                        }
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

struct ScheduledPostOperationsView_Previews: PreviewProvider {
    static var previews: some View {
        PostOperationsView(postID: .constant("test"), path: .constant(NavigationPath()))
    }
}
