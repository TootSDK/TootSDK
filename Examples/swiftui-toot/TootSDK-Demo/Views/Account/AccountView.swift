//
//  AccountView.swift
//  SwiftUI-Toot
//
//  Created by dave on 21/12/22.
//

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
                AsyncImage(url: URL(string: account.avatar)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80, alignment: .topLeading)
                
                Spacer()
            }
            
            AccountItemView(description: "displayName", value: account.displayName)
            AccountItemView(description: "username", value: account.username)

            if let relationship {
                RelationshipView(relationship: relationship)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(account.displayName ?? "?")
        .onAppear {
            Task {
                self.relationship = try await self.tootManager.currentClient.getRelationships(by: [account.id]).first
            }
        }
    }
}
