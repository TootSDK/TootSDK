import Fluent
import LeafKit
import TootSDK
import Vapor

struct TootController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tootRoutes = routes.grouped("toot")
        tootRoutes.get("callback", use: callback)
        tootRoutes.get("me", use: me)
        tootRoutes.post("logout", use: logout)
        tootRoutes.post("login", use: login)
        tootRoutes.post("toot", use: postToot)
        tootRoutes.post("tootaction", use: tootAction)
    }
    
    func logout(req: Request) async throws -> Response {
        try await UserSession.query(on: req.db).delete()
        return req.redirect(to: "/")
    }
    
    func login(req: Request) async throws -> Response {
        let loginRequest = try req.content.decode(LoginRequest.self)
        guard let serverURL = URL(string: loginRequest.url) else {
            throw Abort(.badRequest)
        }
        
        // delete old sessions, this example doesn't support multiple accounts yet
        for session in try await UserSession.query(on: req.db).all() {
            try await session.delete(on: req.db)
        }
        // create a new user session
        let userSession = UserSession(
            id: UUID(), serverUrl: loginRequest.url, clientId: nil, clientSecret: nil, accessToken: nil)
        try await userSession.save(on: req.db)
        
        let client = TootClient(instanceURL: serverURL, scopes: scopes)
        
        guard
            let authorizeURL = try await client.createAuthorizeURL(
                server: serverURL, callbackUrl: callbackURL)
        else {
            req.logger.error("Failed to obtain authorizeURL")
            throw Abort(.internalServerError)
        }
        
        // Store the client id and secret for future calls
        userSession.clientId = client.currentApplicationInfo?.clientId
        userSession.clientSecret = client.currentApplicationInfo?.clientSecret
        try await userSession.update(on: req.db)
        
        return req.redirect(to: authorizeURL.absoluteString)
    }
    
    func callback(req: Request) async throws -> Response {
        guard let code: String = req.query["code"] else {
            req.logger.error(
                "Expected a code query parameter from the fedi server but it wasn't provided.")
            throw Abort(.badRequest)
        }
        
        guard let userSession = try await UserSession.query(on: req.db).first() else {
            req.logger.error("Expected a user session. Did you login already?")
            throw Abort(.badRequest)
        }
        guard let serverURL = URL(string: userSession.serverUrl) else {
            req.logger.error("Failed to convert the serverURL to a URL.")
            throw Abort(.badRequest)
        }
        guard let clientId = userSession.clientId else {
            req.logger.error("Expected a user session with a clientId. Did you login already?")
            throw Abort(.badRequest)
        }
        guard let clientSecret = userSession.clientSecret else {
            req.logger.error("Expected a user session with a clientSecret. Did you login already?")
            throw Abort(.badRequest)
        }
        let client = TootClient(session: .shared, instanceURL: serverURL, scopes: scopes)
        guard
            let accessToken = try await client.collectToken(
                code: code, clientId: clientId, clientSecret: clientSecret, callbackUrl: callbackURL)
        else {
            req.logger.error("Did not receive any accessToken from the fedi server.")
            throw Abort(.internalServerError)
        }
        
        userSession.accessToken = accessToken
        try await userSession.update(on: req.db)
        
        return req.redirect(to: "/toot/me")
    }
    
    /// Helper method to create an instance of `TootClient` based on access token data
    /// available in session storage
    /// - Parameter req: The current request
    /// - Returns: an instance of TootClient or `nil` if data is missing in the session storage
    func getAuthenticatedClient(req: Request) async throws -> TootClient? {
        guard let userSession = try await UserSession.query(on: req.db).first() else {
            print("Expected a user session. Did you login already?")
            return nil
        }
        
        guard let accessToken: String = userSession.accessToken else {
            print("No accessToken available, must login first")
            return nil
        }
        
        guard let serverURL = URL(string: userSession.serverUrl) else {
            print("Failed to convert the serverURL to a URL.")
            throw Abort(.badRequest)
        }
        
        return TootClient(session: .shared, instanceURL: serverURL, accessToken: accessToken)
    }
}

let callbackURL = "http://localhost:8080/toot/callback"  // "urn:ietf:wg:oauth:2.0:oob"
let scopes = ["read", "write", "follow", "push", "admin:read"]

struct LoginRequest: Content {
    var url: String
}

struct Post: Encodable {
    var id: String
    var text: String
    var avatar: String
    var author: String
    var favourited: Bool
}

extension Post {
    init(status: Status) {
        id = status.id
        text = status.content ?? ""
        avatar = status.account.avatar
        author = status.account.displayName ?? ""
        favourited = status.favourited ?? false
    }
}
