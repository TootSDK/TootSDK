//
//  TootSDK_DemoApp.swift
//  TootSDK-Demo
//
//  Created by dave on 6/11/22.
//

import SwiftUI
import TootSDK

@main
struct TootSDK_DemoApp: App {
    @StateObject var tootManager: TootManager = TootManager()

    @State var authIsPresented: Bool = true

    var body: some Scene {
        WindowGroup {
            TabView {
                MakePostView()
                    .tabItem {
                        Label("Make Post", systemImage: "plus.message")
                    }

                FeedSelectionView()
                    .tabItem {
                        Label("Browse Feed", systemImage: "list.bullet.rectangle")
                    }

                UserAccountView()
                    .tabItem {
                        Label("Account", systemImage: "person.fill")
                    }

                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
            }
            .onAppear {
                self.authIsPresented = !self.tootManager.authenticated
            }
            .onChange(of: tootManager.authenticated) { authenticated in
                authIsPresented = !authenticated
            }
            .fullScreenCover(isPresented: $authIsPresented) {
                AuthorizeView()
            }
            .environmentObject(tootManager)
        }
    }

}
