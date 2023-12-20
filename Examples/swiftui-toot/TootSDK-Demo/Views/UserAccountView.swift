//
//  AccountView.swift
//  SwiftUI-Toot
//
//  Created by dave on 26/11/22.
//

import SwiftUI
import TootSDK

struct UserAccountView: View {
    @EnvironmentObject var tootManager: TootManager

    var body: some View {
        NavigationView {
            VStack {
                Button {
                    tootManager.signOut()
                } label: {
                    Text("Sign out")
                }
            }
            .navigationTitle("Account")
        }
    }
}

struct UserAccountView_Previews: PreviewProvider {
    static var previews: some View {
        UserAccountView()
    }
}
