//
//  AccountView.swift
//  SwiftUI-Toot
//
//  Created by dave on 21/12/22.
//

import EmojiText
import NukeUI
import SwiftUI
import TootSDK

struct AccountView: View {
    @EnvironmentObject var tootManager: TootManager

    @State var relationship: Relationship? = nil
    @State var showingReblogs: Bool = false
    @State var notify: Bool = false

    var account: Account

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                LazyImage(url: URL(string: account.avatar))
                    .frame(width: 80, height: 80, alignment: .topLeading)

                Spacer()
            }

            AccountItemView(description: "displayName") {
                EmojiText(
                    markdown: account.displayName ?? "",
                    emojis: account.emojis.remoteEmojis())
            }

            AccountItemView(description: "username", value: account.username)

            if let relationship {
                RelationshipView(relationship: relationship)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Account")
        .onAppear {
            Task {
                self.relationship = try await self.tootManager.currentClient.getRelationships(by: [account.id]).first
            }
        }
    }
}
