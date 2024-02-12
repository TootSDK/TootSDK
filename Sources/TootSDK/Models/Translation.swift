//
//  Translation.swift
//
//
//  Created by Philip Chu on 1/30/24.
//

import Foundation

public struct Translation: Codable {

    /// HTML-encoded translated content of the status.
    public var content: String
    /// The translated spoiler warning of the status.
    /// The Mastodon spec incorrectly lists this as spoiler_warning.
    public var spoilerText: String
    /// The translated poll options of the status.
    /// The Mastodon spec incorrectly lists this as an array.
    public var poll: Poll?
    /// The translated media descriptions of the status
    public var mediaAttachments: [MediaAttachment]
    /// The language of the source text, as auto-detected by the machine translation provider.
    /// ISO 639 language code
    public var detectedSourceLanguage: String
    /// The service that provided the machine translation.
    public var provider: String
    /// The target language
    /// Not in the Mastodon spec, but in the Mastodon code
    public var language: String

    public struct MediaAttachmentTranslation: Codable, Hashable, Identifiable, Sendable {

        public init(
            id: String,
            description: String? = nil
        ) {
            self.id = id
            self.description = description
        }

        /// The ID of the attachment in the database.
        public var id: String
        /// Alternate text that describes what is in the media attachment, to be used for the visually impaired or when media attachments do not load.
        public var description: String?
    }

    public struct PollTranslation: Codable, Hashable, Identifiable, Sendable {
        public init(
            id: String,
            options: [Poll.Option]
        ) {
            self.id = id
            self.options = options
        }

        /// The ID of the poll in the database.
        public var id: String
        /// Possible answers for the poll.
        public var options: [Option]

        public struct Option: Codable, Hashable, Sendable {
            public init(title: String) {
                self.title = title
            }

            /// The text value of the poll option. String.
            public var title: String
        }
    }
}
