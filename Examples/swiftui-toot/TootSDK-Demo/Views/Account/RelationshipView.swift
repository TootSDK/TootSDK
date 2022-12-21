//
//  RelationshipView.swift
//  SwiftUI-Toot
//
//  Created by dave on 21/12/22.
//

import SwiftUI
import TootSDK

struct RelationshipView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @State var relationship: Relationship
    @State var showingReblogs: Bool = false
    @State var notifying: Bool = false
    
    var body: some View {
        VStack {
            AccountItemView(description: "Following", value: "\(relationship.following)")
            Toggle("Showing Boosts:", isOn: $showingReblogs)
            Toggle("Notifying:", isOn: $notifying)
        }
        .onChange(of: relationship) { newValue in
            showingReblogs = newValue.showingReblogs ?? false
        }
        .onChange(of: showingReblogs) { newValue in
            self.refreshAccount()
        }
        .onChange(of: notifying) { newValue in
            self.refreshAccount()
        }
    }
    
    func refreshAccount() {
        Task {
            self.relationship = try await tootManager.currentClient.followAccount(by: relationship.id, params: FollowAccountParams(showingReblogs: showingReblogs, notify: notifying))
        }
    }
}
