//
//  TootClient+Account.swift
//  
//
//  Created by dave on 25/11/22.
//

import Foundation

extension TootClient {
    public func verifyCredentials() async throws -> Account? {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", "verify_credentials"])
            $0.method = .get
        }
        return try await fetch(Account.self, req)
    }
        
    public func getAccount(by id: String) async throws -> Account? {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "accounts", id])
            $0.method = .get
        }
        return try await fetch(Account.self, req)
    }
}
