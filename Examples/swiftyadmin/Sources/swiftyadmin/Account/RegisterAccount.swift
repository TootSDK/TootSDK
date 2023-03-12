// Created by konstantin on 11/03/2023.
// Copyright (c) 2022. All rights reserved.

import ArgumentParser
import Foundation
import TootSDK

struct RegisterAccount: AsyncParsableCommand {

  @Option(name: .short, help: "URL to the instance to connect to")
  var url: String

  @Option(name: .short, help: "Username")
  var name: String

  @Option(name: .short, help: "Email")
  var email: String

  @Option(name: .short, help: "Password")
  var password: String

  mutating func run() async throws {
    guard let registerToken = try await login() else {
      return
    }

    print("connecting for registration")
    let client = TootClient(instanceURL: URL(string: url)!, accessToken: registerToken)
    try await client.connect()
    let instance = try await client.getInstanceInfo()
    if instance.registrations == false {
      print("Instance is not open for registrations")
      return
    }

    print("register account")
    client.debugOn()
    let params = RegisterAccountParams(
      username: name, email: email, password: password, agreement: true, locale: "en")
    let token = try await client.registerAccount(params: params)
    print("Registration success, access token: (\(token.accessToken ?? "nil"))")
  }

  func login() async throws -> String? {
    guard let serverUrl = URL(string: url) else {
      print("Invalid url")
      return nil
    }
    let scopes: [String] = ["read", "write:accounts"]

    let callbackURI: String = "urn:ietf:wg:oauth:2.0:oob"
    let client = TootClient(instanceURL: serverUrl, scopes: scopes)

    let _ = try await client.createAuthorizeURL(
      server: serverUrl, callbackURI: callbackURI)

    guard let clientId = client.currentApplicationInfo?.clientId,
      let clientSecret = client.currentApplicationInfo?.clientSecret
    else {
      print("Did not receive client id and secret as expected")
      return nil
    }

    print("Obtaining client access token")
    let accessToken = try await client.collectRegistrationToken(
      clientId: clientId, clientSecret: clientSecret, callbackURI: callbackURI)

    return accessToken
  }
}
