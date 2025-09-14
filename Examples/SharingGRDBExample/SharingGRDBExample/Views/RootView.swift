//
//  RootView.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import AuthenticationServices
import SharingGRDB
import SwiftUI
import TootSDK

struct RootView: View {

    @FetchOne
    private var currentCredential: ServerCredential?

    @FetchAll
    private var posts: [DisplayPost]

    @State private var serverURL = "https://mastodon.social"
    @State private var isLoading = false
    @State private var client: TootClient?
    @State private var showingAuthSession = false

    var body: some View {
        NavigationStack {
            VStack {
                if currentCredential != nil {
                    // Authenticated view showing posts
                    authenticatedView
                } else {
                    // Login view for entering server URL
                    loginView
                }
            }
            .navigationTitle("TootSDK Example")
            .toolbar {
                if currentCredential != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Sign Out") {
                            signOut()
                        }
                    }
                }
            }
        }
        .task {
            // If you already have a credential, use it to create a TootClient
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

    @ViewBuilder
    private var authenticatedView: some View {
        if posts.isEmpty {
            VStack(spacing: 20) {
                ProgressView()
                Text("Loading posts...")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(posts) { post in
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.authorName)
                        .font(.headline)
                    Text(post.content)
                        .font(.body)
                        .lineLimit(5)
                    Text(post.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func startAuthentication() async {

        guard let url = URL(string: self.serverURL) else {
            print("Invalid server URL")
            return
        }

        do {
            // Let's create a TootClient which will execute the authentication
            let newClient = try await TootClient(
                connect: url,
                clientName: "TootSDK SharingGRDB Example",
                scopes: ["read"]
            )

            self.client = newClient

            // Present authentication session
            let accessToken = try await newClient.presentSignIn(
                callbackURI: "tootsdk-example://oauth",
                prefersEphemeralWebBrowserSession: false
            )

            // Save credential so it can be re-used later
            let credential = ServerCredential(
                host: url.absoluteString,
                accessToken: accessToken
            )

            @Dependency(\.defaultDatabase) var database
            try await database.write { db in
                try ServerCredential.insert {
                    credential
                }
                .execute(db)
            }
            await fetchPosts()

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

            // Verify credentials are still valid and fetch posts
            _ = try await newClient.verifyCredentials()
            await fetchPosts()
        } catch {
            // Token might be invalid, clear credentials
            print(error.localizedDescription)
            signOut()
        }
    }

    private func fetchPosts() async {
        guard let client else { return }

        do {
            // Fetch home timeline
            let timeline = try await client.getTimeline(.home)

            // Convert to DisplayPost objects
            let newPosts = timeline.result.compactMap { post in
                // TootSDK provides renderers to handle post formatting
                // You can make your own renderer for custom handling!
                let renderedPost: String = AttributedStringRenderer().render(html: post.content ?? "").plainString

                return DisplayPost(
                    id: post.id,
                    authorName: post.account.displayName ?? post.account.username ?? "",
                    authorUsername: post.account.acct,
                    content: renderedPost,
                    createdAt: post.createdAt,
                    url: post.url ?? post.uri
                )
            }

            @Dependency(\.defaultDatabase) var database
            try await database.write { db in
                try DisplayPost.delete().execute(db)

                try DisplayPost.upsert {
                    newPosts
                }
                .execute(db)
            }
        } catch {
            print("Failed to fetch posts: \(error)")
        }
    }

    private func signOut() {
        do {
            // Clear all credentials and posts
            @Dependency(\.defaultDatabase) var database
            try database.write { db in
                try ServerCredential.delete().execute(db)
                try DisplayPost.delete().execute(db)
            }
            // Reset state
            client = nil
            serverURL = ""
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
