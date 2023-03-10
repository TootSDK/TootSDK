//
//  TootClient+Post.swift
//  
//
//  Created by dave on 25/11/22.
//

import Foundation

public extension TootClient {
    
    /// Publishes the post based on the components provided
    /// - Parameter PostParams:post components to be published
    /// - Returns: the published post, if successful, throws an error if not
    func publishPost(_ params: PostParams) async throws -> Post {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses"])
            $0.method = .post
            $0.body = try .multipart(params, boundary: UUID().uuidString)
        }
        return try await fetch(Post.self, req)
    }
    
    /// Edit a given post to change its text, sensitivity, media attachments, or poll. Note that editing a poll’s options will reset the votes.
    /// - Parameter id: the ID of the psot to be changed
    /// - Parameter params: the updated content of the post to be posted
    /// - Returns: the post after the update
    func editPost(id: String, _ params: EditPostParams) async throws -> Post {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .put
            $0.body = try .multipart(params, boundary: UUID().uuidString)
        }
        return try await fetch(Post.self, req)
    }
    
    /// Gets a single post
    /// - Parameter id: the ID of the post to be retrieved
    /// - Returns: the post retrieved, if successful, throws an error if not
    func getPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .get
        }
        return try await fetch(Post.self, req)
    }
    
    func getContext(id: String) async throws -> Context {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "context"])
            $0.method = .get
        }
        return try await fetch(Context.self, req)
    }
}

public extension TootClient {
    
    /// Deletes a single post
    /// - Parameter id: the ID of the post to be deleted
    /// - Returns: the post deleted (for delete and redraft), if successful, throws an error if not
    func deletePost(id: String) async throws -> Post? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .delete
        }
        return try await fetch(Post.self, req)
    }
    
}

public extension TootClient {
    
    func favouritePost(id: String) async throws -> Post? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "favourite"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
    func unfavouritePost(id: String) async throws -> Post? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unfavourite"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
}

public extension TootClient {
    
    func boostPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "reblog"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
    func unboostPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unreblog"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
}

public extension TootClient {
    
    func bookmarkPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "bookmark"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
    func unbookmarkPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unbookmark"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
}

public extension TootClient {
    
    func mutePost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "mute"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
    func unmutePost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unmute"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
}

public extension TootClient {
    
    func pinPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "pin"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
    
    func unpinPost(id: String) async throws -> Post {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unpin"])
            $0.method = .post
        }
        return try await fetch(Post.self, req)
    }
}

public extension TootClient {
    
    func getAccountsBoosted(id: String) async throws -> [Account] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "reblogged_by"])
            $0.method = .get
        }
        
        let accounts = try await fetch([Account].self, req)
        return accounts.compactMap({ $0 })
    }
    
    func getAccountsFavourited(id: String) async throws -> [Account] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "favourited_by"])
            $0.method = .get
        }
        
        let accounts = try await fetch([Account].self, req)
        return accounts.compactMap({ $0 })
    }
    
}

public extension TootClient {
    
    func getHistory(id: String) async throws -> [PostEdit] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "history"])
            $0.method = .get
        }
        
        let postEdits = try await fetch([PostEdit].self, req)
        return postEdits.compactMap({ $0 })
    }
    
}

public extension TootClient {
    
    /// Obtain the source properties for a status so that it can be edited.
    func getPostSource(id: String) async throws -> PostSource {
        guard flavour != .friendica else { throw TootSDKError.unsupportedFlavour(current: flavour, required: TootSDKFlavour.allCases.filter({$0 != .friendica})) }
        
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "source"])
            $0.method = .get
        }
        
        return try await fetch(PostSource.self, req)
    }
    
}

public extension TootClient {

    /// Obtain a poll with the specified `id`.
    func getPoll(id: Poll.ID) async throws -> Poll {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "polls", id])
            $0.method = .get
        }

        return try await fetch(Poll.self, req)
    }

    /// Vote on a poll.
    ///
    /// - Parameters:
    ///   - id: The ID of the Poll.
    ///   - choices: Set of indices representing votes for each option (starting from 0).
    /// - Returns: The Poll that was voted on.
    @discardableResult
    func votePoll(id: Poll.ID, choices: IndexSet) async throws -> Poll {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "polls", id, "votes"])
            $0.method = .post
            $0.body = try .form(queryItems: choices.map { index in
                URLQueryItem(name: "choices[]", value: "\(index)")
            })
        }

        return try await fetch(Poll.self, req)
    }

}
