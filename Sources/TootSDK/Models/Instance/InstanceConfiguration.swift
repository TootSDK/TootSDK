public struct InstanceConfiguration: Codable, Hashable, Sendable {
    /// URLs of interest for client apps.
    ///
    /// Only populated by v2 instance API. See ``InstanceV1/InstanceURLs`` for the same values from the v1 API.
    public var urls: URLs?
    /// The instance's VAPID configuration.
    ///
    /// Only populated by v2 instance API.
    public var vapid: VAPID?
    /// Limits related to accounts.
    public var accounts: Accounts?
    /// Limits related to authoring posts.
    public var posts: Posts?
    /// Hints for which attachments will be accepted.
    public var mediaAttachments: MediaAttachments?
    /// Limits related to polls.
    public var polls: Polls?
    /// Hints related to translation.
    ///
    /// Only populated by v2 instance API.
    public var translation: Translation?

    enum CodingKeys: String, CodingKey {
        case urls
        case vapid
        case accounts
        case posts = "statuses"
        case mediaAttachments
        case polls
        case translation
    }

    public struct URLs: Codable, Hashable, Sendable {
        /// Websockets address for the streaming API. String (URL).
        public var streaming: String?

        /// The server status page. String (URL).
        public var status: String?
    }

    public struct Accounts: Codable, Hashable, Sendable {
        /// The maximum number of featured tags allowed for each account.
        public var maxFeaturedTags: Int?
        /// The maximum number of pinned posts for each account.
        public var maxPinnedPosts: Int?

        enum CodingKeys: String, CodingKey {
            case maxFeaturedTags
            case maxPinnedPosts = "maxPinnedStatuses"
        }
    }

    public struct Posts: Codable, Hashable, Sendable {
        /// The maximum number of allowed characters per post.
        public var maxCharacters: Int?
        /// The maximum number of media attachments that can be added to a post.
        public var maxMediaAttachments: Int?
        /// Each URL in a post will be assumed to be exactly this many characters.
        public var charactersReservedPerUrl: Int?
    }

    public struct MediaAttachments: Codable, Hashable, Sendable {
        /// Contains MIME types that can be uploaded.
        public var supportedMimeTypes: [String]?
        /// The maximum size of any uploaded image, in bytes.
        public var imageSizeLimit: Int?
        /// The maximum number of pixels (width times height) for image uploads.
        public var imageMatrixLimit: Int?
        /// The maximum size of any uploaded video, in bytes.
        public var videoSizeLimit: Int?
        /// The maximum frame rate for any uploaded video.
        public var videoFrameRateLimit: Int?
        /// The maximum number of pixels (width times height) for video uploads.
        public var videoMatrixLimit: Int?
    }

    public struct Polls: Codable, Hashable, Sendable {
        /// Each poll is allowed to have up to this many options.
        public var maxOptions: Int?
        /// Each poll option is allowed to have this many characters.
        public var maxCharactersPerOption: Int?
        /// The shortest allowed poll duration, in seconds.
        public var minExpiration: Int?
        /// The longest allowed poll duration, in seconds.
        public var maxExpiration: Int?
    }

    public struct Translation: Codable, Hashable, Sendable {
        /// Whether the translation API is available on this instance.
        public var enabled: Bool?
    }

    public struct VAPID: Codable, Hashable, Sendable {
        /// The instance's VAPID public key, used for push notifications.
        ///
        /// > SeeAlso: This is the same as ``PushSubscription/serverKey``.
        public var publicKey: String?
    }

}
