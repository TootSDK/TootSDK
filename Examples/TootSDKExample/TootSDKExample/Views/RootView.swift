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
    @Query private var posts: [DisplayPost]

    @State private var serverURL = "https://mastodon.social"
    @State private var isLoading = false
    @State private var client: TootClient?
    @State private var showingAuthSession = false

    private var hasCredentials: Bool {
        !credentials.isEmpty
    }

    private var currentCredential: ServerCredential? {
        credentials.first
    }

    var body: some View {
        NavigationStack {
            VStack {
                if hasCredentials {
                    // Authenticated view showing posts
                    authenticatedView
                } else {
                    // Login view for entering server URL
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
                clientName: "TootSDK Example",
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
            modelContext.insert(credential)
            try modelContext.save()

            // Fetch initial posts
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

            // Clear existing posts and add new ones
            for post in posts {
                modelContext.delete(post)
            }

            for post in newPosts {
                modelContext.insert(post)
            }

            try? modelContext.save()
        } catch {
            print("Failed to fetch posts: \(error)")
        }
    }

    private func signOut() {
        // Clear all credentials and posts
        for credential in credentials {
            modelContext.delete(credential)
        }
        for post in posts {
            modelContext.delete(post)
        }
        try? modelContext.save()

        // Reset state
        client = nil
        serverURL = ""
    }
}
