//
//  TootClient+Status.swift
//  
//
//  Created by dave on 25/11/22.
//

import Foundation

public extension TootClient {
    
    /// Publishes the status based on the components provided
    /// - Parameter statusComponents: Status components to be published
    /// - Returns: the published status, if successful, throws an error if not
    func publishStatus(_ params: StatusParams) async throws -> Status {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses"])
            $0.method = .post
            $0.body = try .multipart(params, boundary: UUID().uuidString)
        }
        return try await fetch(Status.self, req)
    }
    
    /// Edit a given status to change its text, sensitivity, media attachments, or poll. Note that editing a poll’s options will reset the votes.
    /// - Parameter id: the ID of the status to be changed
    /// - Parameter params: the updated content of the status to be posted
    /// - Returns: the status after the update
    func editStatus(id: String, _ params: EditStatusParams) async throws -> Status {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .put
            $0.body = try .multipart(params, boundary: UUID().uuidString)
        }
        return try await fetch(Status.self, req)
    }
    
    /// Gets a single status
    /// - Parameter id: the ID of the status to be retrieved
    /// - Returns: the status retrieved, if successful, throws an error if not
    func getStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .get
        }
        return try await fetch(Status.self, req)
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
    
    /// Deletes a single status
    /// - Parameter id: the ID of the status to be deleted
    /// - Returns: the status deleted (for delete and redraft), if successful, throws an error if not
    func deleteStatus(id: String) async throws -> Status? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id])
            $0.method = .delete
        }
        return try await fetch(Status.self, req)
    }
    
}

public extension TootClient {
    
    func favouriteStatus(id: String) async throws -> Status? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "favourite"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
    func unfavouriteStatus(id: String) async throws -> Status? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unfavourite"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
}

public extension TootClient {
    
    func boostStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "reblog"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
    func unboostStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unreblog"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
}

public extension TootClient {
    
    func bookmarkStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "bookmark"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
    func unbookmarkStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unbookmark"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
}

public extension TootClient {
    
    func muteStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "mute"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
    func unmuteStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unmute"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
}

public extension TootClient {
    
    func pinStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "pin"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
    }
    
    func unpinStatus(id: String) async throws -> Status {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "unpin"])
            $0.method = .post
        }
        return try await fetch(Status.self, req)
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
    
    func getHistory(id: String) async throws -> [StatusEdit] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "history"])
            $0.method = .get
        }
        
        let statusEdits = try await fetch([StatusEdit].self, req)
        return statusEdits.compactMap({ $0 })
    }
    
}

public extension TootClient {
    
    func getStatusSource(id: String) async throws -> StatusSource {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses", id, "source"])
            $0.method = .get
        }
        
        return try await fetch(StatusSource.self, req)
    }
    
}
