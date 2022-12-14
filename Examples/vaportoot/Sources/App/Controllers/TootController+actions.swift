import Fluent
import LeafKit
import TootSDK
import Vapor

extension TootController {
    func tootAction(req: Request) async throws -> Response {
        guard let client = try await getAuthenticatedClient(req: req) else {
            return try await logout(req: req)
        }
        
        let actionData = try req.content.decode(TootActionData.self)
        
        guard let status = try await client.getStatus(id: actionData.id) else {
            req.logger.error("The specified status with id \(actionData.id) was not found.")
            throw Abort(.notFound)
        }
        
        
        switch actionData.action {
        case .toggleFavourite:
            let _ =
            status.favourited != true
            ? try await client.favouriteStatus(id: actionData.id)
            : try await client.unfavouriteStatus(id: actionData.id)
        case .toggleBookmark:
            let _ =
            status.bookmarked != true
            ? try await client.bookmarkStatus(id: actionData.id)
            : try await client.unbookmarkStatus(id: actionData.id)
        case .reply:
            return req.redirect(to: "/toot/me?replyTo=\(actionData.id)")
        case .repost:
            _ = try await client.boostStatus(id: actionData.id)
        }
        
        return req.redirect(to: "/toot/me")
    }
}

struct TootActionData: Content {
    /// The id of the post to act upon
    let id: String
    /// The action to perform
    let action: TootActionName
}

enum TootActionName: String, Content {
    case reply
    case repost
    case toggleFavourite
    case toggleBookmark
}


