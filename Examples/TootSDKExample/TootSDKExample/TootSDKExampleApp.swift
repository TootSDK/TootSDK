//
//  TootSDKExampleApp.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import SwiftData
import SwiftUI

@main
struct TootSDKExampleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DisplayPost.self,
            ServerCredential.self,
        ])

        // in-memory store because this is a demo and we don't need anything saved, the app will reset when restarted
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
