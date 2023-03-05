// Created by konstantin on 03/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import MultipartKitTootSDK

public extension TootClient {
    /// Uploads a media to the server so it can be used when publishing posts
    func uploadMedia(_ params: UploadMediaAttachmentParams, mimeType: String) async throws -> MediaAttachment {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "media"])
            $0.method = .post
            
            var parts = [MultipartPart]()
            parts.append(
                MultipartPart(
                    headers: [
                        "Content-Disposition": "form-data; name=\"file\"; filename=\"file\"",
                        "Content-Type": mimeType
                    ],
                    body: params.file
                ))
            parts.append(contentsOf: mediaParts(
                description: params.description,
                focus: params.focus,
                thumbnail: params.thumbnail,
                mimeType: mimeType
            ))
            $0.body = try .multipart(parts, boundary: UUID().uuidString)
        }
        return try await fetch(MediaAttachment.self, req)
    }
    
    /// Retrieve the details of a media attachment that corresponds to the given identifier.
    ///
    /// Requests to Mastodon API flavour return `nil` until the attachment has finished processing.
    /// - Parameter id: The local ID of the attachment.
    /// - Returns: `Attachment` with a `url` to the media if available. `nil` otherwise.
    func getMedia(id: String) async throws -> MediaAttachment? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "media", id])
            $0.method = .get
        }
        
        let (data, response) = try await fetch(req: req)
        
        if flavour == .mastodon && response.statusCode == 206 {
            return nil
        }
        
        return try decode(MediaAttachment.self, from: data)
    }

    /// Update media parameters, before it is posted.
    ///
    /// - Parameter id: the ID of the media attachment to be changed.
    /// - Parameter params: the updated content of the media.
    /// - Returns: the media after the update.
    @discardableResult
    func updateMedia(id: String, _ params: UpdateMediaAttachmentParams) async throws -> MediaAttachment {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "media", id])
            $0.method = .put

            let parts = mediaParts(
                description: params.description,
                focus: params.focus,
                thumbnail: params.thumbnail,
                mimeType: params.thumbnailMimeType
            )
            $0.body = try .multipart(parts, boundary: UUID().uuidString)
        }
        return try await fetch(MediaAttachment.self, req)
    }
}

extension TootClient {

    private func mediaParts(description: String?, focus: String?, thumbnail: Data?, mimeType: String?) -> [MultipartPart] {
        var parts = [MultipartPart]()
        if let description {
            parts.append(
                MultipartPart(
                    headers: [
                        "Content-Disposition": "form-data; name=\"description\""
                    ],
                    body: description
                )
            )
        }
        if let focus {
            parts.append(
                MultipartPart(
                    headers: [
                        "Content-Disposition": "form-data; name=\"focus\""
                    ],
                    body: focus
                )
            )
        }
        if let thumbnail, let mimeType {
            parts.append(
                MultipartPart(
                    headers: [
                        "Content-Disposition": "form-data; name=\"thumbnail\"; filename=\"thumbnail\"",
                        "Content-Type": mimeType
                    ],
                    body: thumbnail
                )
            )
        }
        return parts
    }
}
