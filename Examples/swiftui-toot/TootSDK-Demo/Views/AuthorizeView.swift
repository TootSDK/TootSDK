//
//  AuthorizeView.swift
//  TootSDK-Demo
//
//  Created by dave on 6/11/22.
//

import SwiftUI
import TootSDK
import AuthenticationServices

struct AuthorizeView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @State var urlString: String = ""
    @State var signInDisabled: Bool = false
    @State var test: Bool = false
    
    var body: some View {
        VStack {
            Text("Connect to the Fediverse")
                .font(.title2)
            
            Form {
                
                TextField("https://instance.tld", text: $urlString)
                    .autocorrectionDisabled(true)
#if os(iOS)
                    .autocapitalization(.none)
#endif
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
    }
}

extension AuthorizeView {
    @MainActor func attemptSignIn() async throws {
        guard let url = URL(string: urlString) else { return }        
        try await tootManager.createClientAndPresentSignIn(url)
    }
}

struct AuthorizeView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizeView()
    }
}
