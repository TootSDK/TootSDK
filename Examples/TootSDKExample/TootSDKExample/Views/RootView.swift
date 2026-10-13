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
    @State private var isRefreshingAccountState = false
    @State private var client: TootClient?
    @State private var showCannotRegisterAlert = false
    @State private var signedInAccount: Account? = nil
    
    private var signedInAccountIsFunctional: Bool {
        if let signedInAccount {
            signedInAccount.state?.functional ?? true // if the server did not return a `state`, we have to assume the account is functional
        } else {
            false
        }
    }

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
                    if !signedInAccountIsFunctional {
                        accountStateView
                    } else {
                        TabView {
                            HomeTimelineView(client: client)
                                .tabItem { Label("Home", systemImage: "house") }
                            MentionsTimelineView(client: client)
                                .tabItem { Label("Mentions", systemImage: "at") }
                        }
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
        .task(id: currentCredential) {
            isRefreshingAccountState = true
            defer { isRefreshingAccountState = false }
            if let credential = currentCredential {
                await connectWithCredential(credential)
            }
        }
    }
    
    private struct BooleanView: View {
        var value: Bool
        
        var body: some View {
            if value {
                Label("Yes", systemImage: "checkmark")
                    .foregroundStyle(.green)
            } else {
                Label("No", systemImage: "xmark")
                    .foregroundStyle(.red)
            }
        }
    }
    
    @ViewBuilder
    private var accountStateView: some View {
        if let signedInAccount {
            List {
                Section("Your \(client!.instanceURL, format: .url.host(.always).path(.never).query(.never).scheme(.never).fragment(.never)) account status") {
                    if let state = signedInAccount.state {
                        if let confirmed = state.confirmed {
                            LabeledContent {
                                BooleanView(value: confirmed)
                            } label: {
                                Text("Confirmed email address")
                            }
                        }
                        
                        if let approved = state.approved {
                            LabeledContent {
                                BooleanView(value: approved)
                            } label: {
                                Text("Approved by a moderator")
                            }
                        }
                        
                        if let functional = state.functional {
                            LabeledContent {
                                BooleanView(value: functional)
                            } label: {
                                Text("Account is ready to use")
                            }
                        }
                    }
                }
                .labelStyle(.iconOnly)
                
                if let error = signedInAccount.state?.error {
                    Text(error)
                        .foregroundStyle(.red)
                }
                    
                Button("Refresh") {
                    isRefreshingAccountState = true
                    Task {
                        defer {
                            isRefreshingAccountState = false
                        }
                        if let credential = currentCredential {
                            await connectWithCredential(credential)
                        }
                    }
                }
                .disabled(isRefreshingAccountState)
            }
        } else {
            ProgressView()
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
                isLoading = true
                Task {
                    await startAuthentication()
                }
            }) {
                Text("Sign In")
            }
            .buttonStyle(.borderedProminent)
            .disabled(serverURL.isEmpty || isLoading)
			
            Button {
                isLoading = true
                Task {
                    await startAuthentication(createNewAccount: true)
                }
            } label: {
                Text("Create Account")
            }
            .buttonStyle(.borderedProminent)
            .disabled(serverURL.isEmpty || isLoading)
            .alert("Cannot create account", isPresented: $showCannotRegisterAlert) {
                EmptyView()
            } message:  {
                Text("The server may not support OAuth account creation or may have registrations closed.")
            }
            
            if isLoading {
                ProgressView()
            }

            Spacer()
        }
        .padding()
    }
    
    /// Checks whether the server:
    /// - supports OAuth account creation
    /// - allows registrations
    private func checkRegistrationPossible(_ client: TootClient) async -> Bool {
        guard let instanceInfo = try? await client.getInstanceInfo().v2Representation() else {
            return false
        }
        
        return instanceInfo.registrations.enabled == true && instanceInfo.registrations.oauth == true
    }

    private func startAuthentication(createNewAccount: Bool = false) async {
        defer {
            isLoading = false
        }
        
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
            
            let authorizationParams: AuthorizeURLParams
            if createNewAccount {
                guard await checkRegistrationPossible(newClient) else {
                    print("Server does not support account creation.")
                    showCannotRegisterAlert = true
                    return
                }
                
                authorizationParams = AuthorizeURLParams(prompt: .create)
            } else {
                authorizationParams = AuthorizeURLParams()
            }

            let accessToken = try await newClient.presentSignIn(
                callbackURI: "tootsdk-example://oauth",
                prefersEphemeralWebBrowserSession: false,
                authorizationParams
            )

            // Note: this only stores the access token in SwiftData for demo purposes. In a real app you would want to save credentials to the keychain for security.
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
            signedInAccount = try await newClient.verifyCredentials(allowNonfunctional: true)
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
