//
//  RootView.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import AuthenticationServices
import SwiftData
import SwiftUI
import TootSDK

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [ServerCredential]

    @AppStorage("lastEnteredServerURL") private var serverURL: String = "https://mastodon.social"
    @State private var isLoading = false
    @State private var client: TootClient?

    private var hasCredentials: Bool {
        !credentials.isEmpty
    }

    private var currentCredential: ServerCredential? {
        credentials.first
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let client, hasCredentials {
                    TabView {
                        HomeTimelineView(client: client)
                            .tabItem { Label("Home", systemImage: "house") }
                        MentionsTimelineView(client: client)
                            .tabItem { Label("Mentions", systemImage: "at") }
                    }
                } else {
                    loginView
                }
            }
            .navigationTitle("TootSDK Example")
            .toolbar {
                if hasCredentials {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Sign Out") {
                            signOut()
                        }
                    }
                }
            }
        }
        .task {
            if let credential = currentCredential {
                await connectWithCredential(credential)
            }
        }
    }

    @ViewBuilder
    private var loginView: some View {
        VStack(spacing: 20) {
            Text("Connect to Mastodon")
                .font(.largeTitle)

            Text("Enter your Mastodon server URL")
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 8) {
                TextField("https://mastodon.social", text: $serverURL)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal)

            Button(action: {
                Task {
                    await startAuthentication()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Sign In")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(serverURL.isEmpty || isLoading)

            Spacer()
        }
        .padding()
    }

    private func startAuthentication() async {
        guard let url = URL(string: self.serverURL) else {
            print("Invalid server URL")
            return
        }

        do {
            let newClient = try await TootClient(
                connect: url,
                clientName: "TootSDK Example",
                scopes: ["read"]
            )

            self.client = newClient

            let accessToken = try await newClient.presentSignIn(
                callbackURI: "tootsdk-example://oauth",
                prefersEphemeralWebBrowserSession: false
            )

            let credential = ServerCredential(
                host: url.absoluteString,
                accessToken: accessToken
            )
            modelContext.insert(credential)
            try modelContext.save()

        } catch ASWebAuthenticationSessionError.canceledLogin {
            print("User cancelled, no error message needed")
            return
        } catch {
            print("Authentication failed: \(error.localizedDescription)")
        }
    }

    private func connectWithCredential(_ credential: ServerCredential) async {
        guard let url = URL(string: credential.host) else { return }

        do {
            let newClient = try await TootClient(
                connect: url,
                clientName: "TootSDK Example",
                accessToken: credential.accessToken
            )
            self.client = newClient
            _ = try await newClient.verifyCredentials()
        } catch {
            print(error.localizedDescription)
            signOut()
        }
    }

    private func signOut() {
        for credential in credentials {
            modelContext.delete(credential)
        }
        try? modelContext.save()
        client = nil
    }
}
