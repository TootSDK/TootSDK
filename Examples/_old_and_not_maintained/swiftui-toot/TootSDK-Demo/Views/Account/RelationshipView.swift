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
    @State var muting: Bool = false
    @State var blocking: Bool = false

    @State var followNotify: Bool = false
    @State var followShowingReblogs: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            AccountItemView(description: "Following", value: "\(relationship.following)")
                .frame(alignment: .leading)
            Toggle("Showing Boosts:", isOn: $showingReblogs)
            Toggle("Notifying:", isOn: $notifying)
            Toggle("Muting:", isOn: $muting)
            Toggle("Blocking:", isOn: $blocking)

            buttons()
        }
        .onAppear {
            self.updateTogglesWith(self.relationship)
        }
        .onChange(of: relationship) { newValue in
            self.updateTogglesWith(newValue)
        }
        .onChange(of: showingReblogs) { newValue in
            self.refreshAccount()
        }
        .onChange(of: notifying) { newValue in
            self.refreshAccount()
        }
        .onChange(of: muting) { newValue in
            Task {
                if muting {
                    self.relationship = try await tootManager.currentClient.muteAccount(by: relationship.id)
                } else {
                    self.relationship = try await tootManager.currentClient.unmuteAccount(by: relationship.id)
                }
            }
        }
        .onChange(of: blocking) { newValue in
            Task {
                if blocking {
                    self.relationship = try await tootManager.currentClient.blockAccount(by: relationship.id)
                } else {
                    self.relationship = try await tootManager.currentClient.unblockAccount(by: relationship.id)
                }
            }
        }
    }

    func updateTogglesWith(_ value: Relationship) {
        showingReblogs = value.showingReposts ?? false
        notifying = value.notifying ?? false
        muting = value.muting
        blocking = value.blocking
    }

    @ViewBuilder func buttons() -> some View {
        if relationship.following == true {
            ButtonView(text: "Unfollow") {
                self.relationship = try await tootManager.currentClient.unfollowAccount(by: relationship.id)
            }
        } else {
            HStack {
                ButtonView(text: "Follow") {
                    self.relationship = try await tootManager.currentClient.followAccount(
                        by: relationship.id,
                        params: FollowAccountParams(
                            reposts: followShowingReblogs,
                            notify: followNotify))
                }

                Spacer()

                Toggle("Show Boosts", isOn: $followShowingReblogs)
                Toggle("Show Notify", isOn: $followNotify)
            }
        }
    }

    func refreshAccount() {
        Task {
            self.relationship = try await tootManager.currentClient.followAccount(
                by: relationship.id, params: FollowAccountParams(reposts: showingReblogs, notify: notifying))
        }
    }
}
