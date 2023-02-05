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
            if let description = params.description {
                parts.append(
                    MultipartPart(
                        headers: [
                            "Content-Disposition": "form-data; name=\"description\""
                        ],
                        body: description
                    )
                )
            }
            if let focus = params.focus {
                parts.append(
                    MultipartPart(
                        headers: [
                            "Content-Disposition": "form-data; name=\"focus\""
                        ],
                        body: focus
                    )
                )
            }
            if let thumbnail = params.thumbnail {
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
            $0.body = try .multipart(parts, boundary: UUID().uuidString)
        }
        return try await fetch(MediaAttachment.self, req)
    }
    
    /// Get a media attachment, before it is attached to a status and posted, but after it is accepted for processing.
    /// Use this method to check that the full-sized media has finished processing.
    ///
    /// - Parameter id: The ID of the attachment.
    /// - Returns: `Attachment` if media file was processed, and a `url` to processed media is available. `nil` otherwise.
    func getMedia(id: Attachment.ID) async throws -> Attachment? {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "media", id])
            $0.method = .get
        }
        
        let (data, response) = try await fetch(req: req)
        
        if response.statusCode == 206 {
            return nil
        }
        
        return try decode(Attachment.self, from: data)
    }
}
