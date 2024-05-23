//
//  StreamCategory.swift
//
//
//  Created by Dale Price on 5/23/24.
//

import Foundation

/// The timeline or category that a ``StreamingEvent`` belongs to.
///
/// - SeeAlso: [Mastodon API: Streaming timelines/categories](https://docs.joinmastodon.org/methods/streaming/#streams)
enum StreamCategory: Equatable {
    /// All public posts known to the server. Analogous to the federated timeline.
    case publicTimeline
    /// All public posts known to the server, filtered for media attachments. Analogous to the federated timeline with "only media" enabled.
    case publicMedia
    /// All public posts originating from this server. Analogous to the local timeline.
    case publicLocal
    /// All public posts originating from this server, filtered for media attachments. Analogous to the local timeline with “only media” enabled.
    case publicLocalMedia
    /// All public posts originating from other servers.
    case publicRemote
    /// All public posts originating from other servers, filtered for media attachments.
    case publicRemoteMedia
    /// All public posts using a certain hashtag.
    case hashtag(tag: String)
    /// All public posts using a certain hashtag, originating from this server.
    case localHashtag(tag: String)
    /// Events related to the current user, such as home feed updates and notifications.
    case user
    /// Notifications for the current user.
    case userNotification
    /// Updates to a specific list.
    case list(listID: String)
    /// Updates to direct conversations.
    case direct
}

extension StreamCategory: RawRepresentable {
    typealias rawValue = [String]
    
    init?(rawValue: [String]) {
        switch rawValue.first {
        case "public": self = .publicTimeline
        case "public:media": self = .publicMedia
        case "public:local": self = .publicLocal
        case "public:local:media": self = .publicLocalMedia
        case "public:remote": self = .publicRemote
        case "public:remote:media": self = .publicRemoteMedia
        case "hashtag":
            guard rawValue.count == 2 else { return nil }
            self = .hashtag(tag: rawValue[1])
        case "hashtag:local":
            guard rawValue.count == 2 else { return nil }
            self = .localHashtag(tag: rawValue[1])
        case "user": self = .user
        case "user:notification": self = .userNotification
        case "list":
            guard rawValue.count == 2 else { return nil }
            self = .list(listID: rawValue[1])
        case "direct": self = .direct
        default: return nil
        }
    }
    
    var rawValue: [String] {
        switch self {
        case .publicTimeline: ["public"]
        case .publicMedia: ["public:media"]
        case .publicLocal: ["public:local"]
        case .publicLocalMedia: ["public:local:media"]
        case .publicRemote: ["public:remote"]
        case .publicRemoteMedia: ["public:remote:media"]
        case .hashtag(let tag): ["hashtag", tag]
        case .localHashtag(let tag): ["hashtag:local", tag]
        case .user: ["user"]
        case .userNotification: ["userNotification"]
        case .list(let listID): ["list", listID]
        case .direct: ["direct"]
        }
    }
}
