// Created by konstantin on 03/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import MultipartKitTootSDK

#if canImport(UniformTypeIdentifiers)
    import UniformTypeIdentifiers
#endif

extension TootClient {
    /// Uploads a media to the server so it can be used when publishing posts
    public func uploadMedia(_ params: UploadMediaAttachmentParams, mimeType: String) async throws -> UploadedMediaAttachment {
        let response = try await uploadMediaRaw(params, mimeType: mimeType)
        return response.data
    }

    /// Uploads media and reports its progress.
    ///
    /// - Parameter progress: Called with upload progress from `0` to `1`.
    /// - Returns: The uploaded media attachment.
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    public func uploadMedia(
        _ params: UploadMediaAttachmentParams,
        mimeType: String,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws -> UploadedMediaAttachment {
        progress(0)
        try Task.checkCancellation()
        let req = try mediaUploadRequest(params, mimeType: mimeType)
        let delegate = UploadProgressDelegate(reportProgress: progress)
        let response = try await fetchRaw(
            UploadMediaAttachmentResponse.self,
            req,
            uploadDelegate: delegate
        )
        return Self.uploadedMedia(from: response.data)
    }

    /// Uploads a media to the server with HTTP response metadata
    /// - Returns: TootResponse containing the uploaded media attachment and HTTP metadata
    public func uploadMediaRaw(_ params: UploadMediaAttachmentParams, mimeType: String) async throws -> TootResponse<UploadedMediaAttachment> {
        let req = try mediaUploadRequest(params, mimeType: mimeType)
        let uploadResponse = try await fetchRaw(UploadMediaAttachmentResponse.self, req)

        return TootResponse(
            data: Self.uploadedMedia(from: uploadResponse.data),
            headers: uploadResponse.headers,
            statusCode: uploadResponse.statusCode,
            url: uploadResponse.url,
            rawBody: uploadResponse.rawBody
        )
    }

    private func mediaUploadRequest(_ params: UploadMediaAttachmentParams, mimeType: String) throws -> HTTPRequestBuilder {
        try HTTPRequestBuilder {
            $0.url = getURL(["api", "v2", "media"])
            $0.method = .post

            var parts = [MultipartPart]()
            parts.append(
                MultipartPart(
                    headers: [
                        "Content-Disposition": "form-data; name=\"file\"; filename=\"\(mediaFilename(for: "file", mimeType: mimeType))\"",
                        "Content-Type": mimeType,
                    ],
                    body: params.file
                ))
            parts.append(
                contentsOf: mediaParts(
                    description: params.description,
                    focus: params.focus,
                    thumbnail: params.thumbnail,
                    mimeType: mimeType
                ))
            $0.body = try .multipart(parts, boundary: UUID().uuidString)
        }
    }

    private static func uploadedMedia(from response: UploadMediaAttachmentResponse) -> UploadedMediaAttachment {
        response.url != nil
            ? UploadedMediaAttachment(id: response.id, state: .uploaded)
            : UploadedMediaAttachment(id: response.id, state: .serverProcessing)
    }

    /// Retrieve the details of a media attachment that corresponds to the given identifier.
    ///
    /// Requests to Mastodon API flavour return `nil` until the attachment has finished processing.
    /// - Parameter id: The local ID of the attachment.
    /// - Returns: `Attachment` with a `url` to the media if available. `nil` otherwise.
    public func getMedia(id: String) async throws -> MediaAttachment? {
        let response = try await getMediaRaw(id: id)
        return response.data
    }

    /// Retrieve the details of a media attachment with HTTP response metadata
    ///
    /// - Parameter id: The local ID of the attachment.
    /// - Returns: TootResponse containing the media attachment and HTTP metadata
    /// - Note: For Mastodon servers, status code 206 indicates the media is still processing.
    ///         The response will contain empty/placeholder data in this case.
    public func getMediaRaw(id: String) async throws -> TootResponse<MediaAttachment?> {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "media", id])
            $0.method = .get
        }

        let (data, response) = try await fetch(req: req)

        // Convert headers to [String: String]
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            if let keyString = key as? String, let valueString = value as? String {
                headers[keyString] = valueString
            }
        }

        // For Mastodon, 206 indicates media is still processing
        // We need to return a valid response but with placeholder data
        if flavour == .mastodon && response.statusCode == 206 {
            return TootResponse(
                data: nil,
                headers: headers,
                statusCode: response.statusCode,
                url: response.url,
                rawBody: data
            )
        }

        // For all other cases, decode normally
        let mediaAttachment = try decoder.decode(MediaAttachment.self, from: data)

        return TootResponse(
            data: mediaAttachment,
            headers: headers,
            statusCode: response.statusCode,
            url: response.url,
            rawBody: data
        )
    }

    /// Delete a media attachment that is not currently attached to a status.
    ///
    /// Only supported on Mastodon 4.4 or higher.
    ///
    /// - Parameter id: The ID of the ``MediaAttachment`` in the database.
    public func deleteMedia(id: String) async throws {
        _ = try await deleteMediaRaw(id: id)
    }

    /// Delete a media attachment with HTTP response metadata
    ///
    /// Only supported on Mastodon 4.4 or higher.
    ///
    /// - Parameter id: The ID of the ``MediaAttachment`` in the database.
    /// - Returns: TootResponse containing HTTP metadata (the data field will be Void)
    public func deleteMediaRaw(id: String) async throws -> TootResponse<Void> {
        try requireFeature(.deleteMedia)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "media", id])
            $0.method = .delete
        }

        let (data, response) = try await fetch(req: req)

        // Convert headers to [String: String]
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            if let keyString = key as? String, let valueString = value as? String {
                headers[keyString] = valueString
            }
        }

        return TootResponse(
            data: (),
            headers: headers,
            statusCode: response.statusCode,
            url: response.url,
            rawBody: data
        )
    }

    /// Update media parameters, before it is posted.
    ///
    /// - Parameter id: the ID of the media attachment to be changed.
    /// - Parameter params: the updated content of the media.
    /// - Returns: the media after the update.
    @discardableResult
    public func updateMedia(id: String, _ params: UpdateMediaAttachmentParams) async throws -> MediaAttachment {
        let response = try await updateMediaRaw(id: id, params)
        return response.data
    }

    /// Update media parameters with HTTP response metadata
    ///
    /// - Parameter id: the ID of the media attachment to be changed.
    /// - Parameter params: the updated content of the media.
    /// - Returns: TootResponse containing the updated media attachment and HTTP metadata
    @discardableResult
    public func updateMediaRaw(id: String, _ params: UpdateMediaAttachmentParams) async throws -> TootResponse<MediaAttachment> {
        let req = try HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "media", id])
            $0.method = .put

            if flavour == .pixelfed {
                $0.body = try .json(params, encoder: encoder)
            } else {
                let parts = mediaParts(
                    description: params.description,
                    focus: params.focus,
                    thumbnail: params.thumbnail,
                    mimeType: params.thumbnailMimeType
                )
                $0.body = try .multipart(parts, boundary: UUID().uuidString)
            }
        }
        return try await fetchRaw(MediaAttachment.self, req)
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
                        "Content-Disposition": "form-data; name=\"thumbnail\"; filename=\"\(mediaFilename(for: "thumbnail", mimeType: mimeType))\"",
                        "Content-Type": mimeType,
                    ],
                    body: thumbnail
                )
            )
        }
        return parts
    }

    private func mediaFilename(for name: String, mimeType: String) -> String {
        let mimeType = Self.normalizedMimeType(mimeType)
        guard let fileExtension = Self.preferredFilenameExtension(for: mimeType) else {
            return name
        }
        return "\(name).\(fileExtension)"
    }

    private static func preferredFilenameExtension(for mimeType: String) -> String? {
        #if canImport(UniformTypeIdentifiers)
            if let fileExtension = UTType(mimeType: mimeType)?.preferredFilenameExtension {
                return fileExtension
            }
        #endif
        return mediaFileExtensions[mimeType]
    }

    private static func normalizedMimeType(_ mimeType: String) -> String {
        mimeType
            .split(separator: ";", maxSplits: 1)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""
    }

    // MIME types advertised by the supported Fediverse flavour fixtures.
    private static let mediaFileExtensions = [
        "application/octet-stream": "bin",
        "application/ogg": "ogg",
        "audio/3gp2": "3g2",
        "audio/3gpp": "3gp",
        "audio/3gpp2": "3g2",
        "audio/aac": "aac",
        "audio/flac": "flac",
        "audio/it": "it",
        "audio/m4a": "m4a",
        "audio/mod": "mod",
        "audio/mp2": "mp2",
        "audio/mp3": "mp3",
        "audio/mp4": "mp4",
        "audio/mpeg": "mp3",
        "audio/ogg": "ogg",
        "audio/opus": "opus",
        "audio/s3m": "s3m",
        "audio/vnd.wave": "wav",
        "audio/vorbis": "ogg",
        "audio/wav": "wav",
        "audio/wave": "wav",
        "audio/webm": "webm",
        "audio/x-flac": "flac",
        "audio/x-it": "it",
        "audio/x-m4a": "m4a",
        "audio/x-matroska": "mka",
        "audio/x-mod": "mod",
        "audio/x-ms-wma": "wma",
        "audio/x-pn-wave": "wav",
        "audio/x-s3m": "s3m",
        "audio/x-wav": "wav",
        "audio/x-xm": "xm",
        "audio/xm": "xm",
        "image/apng": "apng",
        "image/avif": "avif",
        "image/bmp": "bmp",
        "image/gif": "gif",
        "image/heic": "heic",
        "image/heif": "heif",
        "image/jpeg": "jpeg",
        "image/png": "png",
        "image/tiff": "tiff",
        "image/webp": "webp",
        "image/x-icon": "ico",
        "video/3gp2": "3g2",
        "video/3gpp": "3gp",
        "video/3gpp2": "3g2",
        "video/mp4": "mp4",
        "video/mpeg": "mpg",
        "video/ogg": "ogm",
        "video/quicktime": "mov",
        "video/vnd.avi": "avi",
        "video/webm": "webm",
        "video/x-m4v": "m4v",
        "video/x-matroska": "mkv",
        "video/x-ms-asf": "asf",
        "video/x-ms-wmv": "wmv",
        "video/x-msvideo": "avi",
    ]
}

extension TootFeature {
    /// Delete media attachment feature - requires Mastodon API version 4
    /// This feature requires API version checking from InstanceV2.
    /// No fallback to display version is provided since Mastodon supports instanceV2.
    public static let deleteMedia = TootFeature(requirements: [
        .from(.mastodon, version: 4)
    ])
}
