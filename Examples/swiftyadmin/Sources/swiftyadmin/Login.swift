// Created by konstantin on 17/12/2022.
// Copyright (c) 2022. All rights reserved.

import ArgumentParser
import Foundation
import TootSDK

struct Login: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(
    name: .short,
    help:
      "List of scopes to request during authentication. e.g. '-s admin:read -s admin:write'"
  )
  var scopes: [String] = ["read", "write", "follow", "push"]

  mutating func run() async throws {
    guard let serverUrl = URL(string: url) else {
      print("Invalid url")
      return
    }

    print("Logging into (serverUrl.absoluteString) with scopes \(scopes.joined(separator: ", "))")
    let callbackUrl: String = "urn:ietf:wg:oauth:2.0:oob"
    let client = TootClient(instanceURL: serverUrl, scopes: scopes)
    // TODO: why do we need server param here, it's already set?

    guard
      let authUrl = try await client.createAuthorizeURL(
        server: serverUrl, callbackUrl: callbackUrl)
    else {
      print("failed to generate auth url")
      return
    }

    guard let clientId = client.currentApplicationInfo?.clientId,
      let clientSecret = client.currentApplicationInfo?.clientSecret
    else {
      print("Did not receive client id and secret as expected")
      return
    }
    print("Client id: \(clientId)")
    print("Client secret: \(clientSecret)")
    print(
      "Please navigate to the following link to complete the authentication:\n\r\(authUrl.absoluteString)"
    )
    print("Paste the access code and hit Enter to continue:\n\r")
    guard let code = readLine() else {
      print("Access code is required to complete authorization.")
      return
    }
    let accessToken = try await client.collectToken(
      code: code, clientId: clientId, clientSecret: clientSecret, callbackUrl: callbackUrl)

    guard let accessToken = accessToken else {
      print("Did not receive access token as expected")
      return
    }

    print("You can use the following access token as a bearer token: \(accessToken)")
  }
}
