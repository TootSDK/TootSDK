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
    /// Whether federation is limited to explicitly allowed domains.
    public var limitedFederation: Bool?
    /// Access restrictions on timelines.
    ///
    /// Only populated by the v2 instance API.
    public var timelinesAccess: TimelinesAccess?

    public init(
        urls: URLs? = nil, vapid: VAPID? = nil, accounts: Accounts? = nil, posts: Posts? = nil, mediaAttachments: MediaAttachments? = nil,
        polls: Polls? = nil, translation: Translation? = nil, limitedFederation: Bool? = nil, timelinesAccess: TimelinesAccess? = nil
    ) {
        self.urls = urls
        self.vapid = vapid
        self.accounts = accounts
        self.posts = posts
        self.mediaAttachments = mediaAttachments
        self.polls = polls
        self.translation = translation
        self.limitedFederation = limitedFederation
        self.timelinesAccess = timelinesAccess
    }

    enum CodingKeys: String, CodingKey {
        case urls
        case vapid
        case accounts
        case posts = "statuses"
        case mediaAttachments
        case polls
        case translation
        case limitedFederation
        case timelinesAccess
    }

    public struct URLs: Codable, Hashable, Sendable {
        /// Websockets address for the streaming API. String (URL).
        public var streaming: String?

        /// The server status page. String (URL).
        public var status: String?

        /// The server's about page. String (URL).
        public var about: String?

        /// The server's privacy policy webpage. String (URL).
        public var privacyPolicy: String?

        /// The server's terms of service webpage. String (URL).
        public var termsOfService: String?

        public init(
            streaming: String? = nil, status: String? = nil, about: String? = nil, privacyPolicy: String? = nil, termsOfService: String? = nil
        ) {
            self.streaming = streaming
            self.status = status
            self.about = about
            self.privacyPolicy = privacyPolicy
            self.termsOfService = termsOfService
        }
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

        public init(maxFeaturedTags: Int? = nil, maxPinnedPosts: Int? = nil) {
            self.maxFeaturedTags = maxFeaturedTags
            self.maxPinnedPosts = maxPinnedPosts
        }
    }

    public struct Posts: Codable, Hashable, Sendable {
        /// The maximum number of allowed characters per post.
        public var maxCharacters: Int?
        /// The maximum number of media attachments that can be added to a post.
        public var maxMediaAttachments: Int?
        /// Each URL in a post will be assumed to be exactly this many characters.
        public var charactersReservedPerUrl: Int?

        public init(maxCharacters: Int? = nil, maxMediaAttachments: Int? = nil, charactersReservedPerUrl: Int? = nil) {
            self.maxCharacters = maxCharacters
            self.maxMediaAttachments = maxMediaAttachments
            self.charactersReservedPerUrl = charactersReservedPerUrl
        }
    }

    public struct MediaAttachments: Codable, Hashable, Sendable {
        /// Contains MIME types that can be uploaded.
        public var supportedMimeTypes: [String]?
        /// The maximum size of a description, in characters.
        public var descriptionLimit: Int?
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

        public init(
            supportedMimeTypes: [String]? = nil, descriptionLimit: Int? = nil, imageSizeLimit: Int? = nil, imageMatrixLimit: Int? = nil,
            videoSizeLimit: Int? = nil, videoFrameRateLimit: Int? = nil, videoMatrixLimit: Int? = nil
        ) {
            self.supportedMimeTypes = supportedMimeTypes
            self.descriptionLimit = descriptionLimit
            self.imageSizeLimit = imageSizeLimit
            self.imageMatrixLimit = imageMatrixLimit
            self.videoSizeLimit = videoSizeLimit
            self.videoFrameRateLimit = videoFrameRateLimit
            self.videoMatrixLimit = videoMatrixLimit
        }
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

        public init(maxOptions: Int? = nil, maxCharactersPerOption: Int? = nil, minExpiration: Int? = nil, maxExpiration: Int? = nil) {
            self.maxOptions = maxOptions
            self.maxCharactersPerOption = maxCharactersPerOption
            self.minExpiration = minExpiration
            self.maxExpiration = maxExpiration
        }
    }

    public struct Translation: Codable, Hashable, Sendable {
        /// Whether the translation API is available on this instance.
        public var enabled: Bool?

        public init(enabled: Bool? = nil) {
            self.enabled = enabled
        }
    }

    public struct VAPID: Codable, Hashable, Sendable {
        /// The instance's VAPID public key, used for push notifications.
        ///
        /// > SeeAlso: This is the same as ``PushSubscription/serverKey``.
        public var publicKey: String?

        public init(publicKey: String? = nil) {
            self.publicKey = publicKey
        }
    }

    public struct TimelinesAccess: Codable, Hashable, Sendable {

        /// Access restrictions for a feed.
        public enum FeedAccess: String, Codable, Hashable, Sendable {
            /// Access to posts in this feed is available to both visitors and logged in users.
            case `public`
            /// Access to posts in this feed requires authentication.
            case authenticated
            /// Access to posts in this feed is only possible if the current user's ``TootRole/permissions`` include the "View live and topic feeds" permission.
            case disabled
        }

        /// Specifies the level of access available for local and remote posts in a given feed.
        public struct FeedSet: Codable, Hashable, Sendable {
            /// Access restrictions on local posts in this feed.
            public var local: OpenEnum<FeedAccess>?
            /// Access restrictions on remote posts in this feed.
            public var remote: OpenEnum<FeedAccess>?

            public init(local: FeedAccess? = nil, remote: FeedAccess? = nil) {
                if let local {
                    self.local = .some(local)
                }
                if let remote {
                    self.remote = .some(remote)
                }
            }
        }

        /// Access restrictions on public "firehose" feeds (i.e. local and federated timelines).
        public var liveFeeds: FeedSet?

        /// Access restrictions on hashtag feeds.
        public var hashtagFeeds: FeedSet?

        /// Access restrictions on trending link feeds.
        public var trendingLinkFeeds: FeedSet?
    }

}
