// Created by konstantin on 03/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import MultipartKit

public extension TootClient {
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
}
