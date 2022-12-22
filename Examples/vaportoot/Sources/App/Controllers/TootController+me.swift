// Created by konstantin on 09/12/2022.
// Copyright (c) 2022. All rights reserved.

import Fluent
import LeafKit
import TootSDK
import Vapor

extension TootController {
    func me(req: Request) async throws -> Response {
        guard let client = try await getAuthenticatedClient(req: req) else {
            return try await logout(req: req)
        }
        
        guard let account = try? await client.verifyCredentials() else {
            throw Abort(.notFound)
        }
        
        // if replying to a post, add the content to context
        let query = try req.query.decode(MeQuery.self)
        var replyText = ""
        if let replyPostId = query.replyTo {
            let replyToPost = try await client.getStatus(id: replyPostId)
            replyText = replyToPost.content?.raw ?? ""
        }
        let posts = try await client.getHomeTimeline()
        let context = MeContext(
            note: account.note,
            name: account.tootRichDisplayName ?? "",
            avatar: account.avatar,
            posts: posts.result.map({ Post(status: $0) }),
            replyText: replyText,
            replyId: query.replyTo)
        return try await req.view.render(
            "user",
            context
        ).encodeResponse(for: req)
    }
}

struct MeContext: Encodable {
    var note: String
    var name: String
    var avatar: String
    var posts: [Post]
    var replyText: String?
    var replyId: String?
}

struct MeQuery: Content {
    var replyTo: String?
}
