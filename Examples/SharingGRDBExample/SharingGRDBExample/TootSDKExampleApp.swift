//
//  TootSDKExampleApp.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import Dependencies
import SharingGRDB
import SwiftUI

@main
struct TootSDKExampleApp: App {

    init() {
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
