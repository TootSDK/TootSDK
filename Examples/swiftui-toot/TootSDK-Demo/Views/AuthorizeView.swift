//
//  AuthorizeView.swift
//  TootSDK-Demo
//
//  Created by dave on 6/11/22.
//

import SwiftUI
import BetterSafariView
import TootSDK

struct AuthorizationDetails: Identifiable {
    var id = UUID()
    var authURL: URL
}

struct AuthorizeView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @State var urlString: String = ""
    @State var signInDisabled: Bool = false
    @State var test: Bool = false
    @State var authorizationDetails: AuthorizationDetails?
    
    var body: some View {
        VStack {
            Text("Connect to the Fediverse")
                .font(.title2)
            
            Form {
                
                TextField("https://instance.tld", text: $urlString)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                
                Button {
                    Task {
                        do {
                            try await attemptSignIn()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } label: {
                    Text("Sign in")
                }
                .disabled(signInDisabled)
            }
        }
        .onChange(of: urlString) { urlString in
            signInDisabled = urlString.isEmpty
        }
        .webAuthenticationSession(item: $authorizationDetails, content: { authorizationDetail in
            WebAuthenticationSession(
                url: authorizationDetail.authURL,
                callbackURLScheme: nil
            ) { callbackUrl, error in
                if let callbackUrl = callbackUrl, error == nil {
                    Task {
                        do {
                            try await tootManager.collectAccessToken(callbackUrl)
                        } catch {
                            debugPrint(error.localizedDescription)
                            
                            switch error as? TootSDKError {
                            case .invalidStatusCode(_, let response):
                                print(response.statusCode)
                            default:
                                print("none")
                            }

                        }
                    }
                } else {
                    debugPrint(callbackUrl ?? "")
                    debugPrint(error?.localizedDescription ?? "")
                }
            }
            .prefersEphemeralWebBrowserSession(false)
        })
    }
}

extension AuthorizeView {
        
    @MainActor func attemptSignIn() async throws {
        guard let url = URL(string: urlString) else { return }
        
        guard
            let authURL = try await tootManager.createClientAndAuthorizeURL(url)
        else {
            return
        }
        
        authorizationDetails = AuthorizationDetails(authURL: authURL)
    }
}

struct AuthorizeView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizeView()
    }
}
