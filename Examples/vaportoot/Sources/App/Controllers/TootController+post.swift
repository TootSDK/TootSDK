import Fluent
import LeafKit
import TootSDK
import Vapor

extension TootController {
    func postToot(req: Request) async throws -> Response {
        guard let client = try await getAuthenticatedClient(req: req) else {
            return try await logout(req: req)
        }

        let postRequest = try req.content.decode(PostRequest.self)

        if let replyId = postRequest.replyId {
            // replying
            let _ = try await client.publishPost(
                .init(
                    post: postRequest.text, inReplyToId: replyId, visibility: .unlisted))
        } else {
            // posting new
            let _ = try await client.publishPost(
                .init(post: postRequest.text, visibility: .unlisted, spoilerText: postRequest.cw))

        }

        return try await me(req: req)
    }
}

struct PostRequest: Content {
    var text: String
    var cw: String?
    var replyId: String?
}
