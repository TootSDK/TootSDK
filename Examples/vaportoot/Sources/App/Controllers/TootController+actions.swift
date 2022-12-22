import Fluent
import LeafKit
import TootSDK
import Vapor

extension TootController {
  func tootAction(req: Request) async throws -> Response {
    guard let client = try await getAuthenticatedClient(req: req) else {
      return try await logout(req: req)
    }
    client.debugOn()
    let actionData = try req.content.decode(TootActionData.self)

    guard let post = try? await client.getPost(id: actionData.id) else {
      req.logger.error("The specified post with id \(actionData.id) was not found.")
      throw Abort(.notFound)
    }

    switch actionData.action {
    case .toggleFavourite:
      let _ =
        post.favourited != true
        ? try await client.favouritePost(id: actionData.id)
        : try await client.unfavouritePost(id: actionData.id)
    case .toggleBookmark:
      let _ =
        post.bookmarked != true
        ? try await client.bookmarkPost(id: actionData.id)
        : try await client.unbookmarkPost(id: actionData.id)
    case .reply:
      return req.redirect(to: "/toot/me?replyTo=\(actionData.id)")
    case .repost:
      _ = try await client.boostPost(id: actionData.id)
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
