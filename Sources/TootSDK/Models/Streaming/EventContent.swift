//
//  EventContent.swift
//
//
//  Created by Dale Price on 5/23/24.
//

import Foundation

/// An event received from the streaming service with associated content.
///
/// - SeeAlso: [Mastodon API: Event types and payloads](https://docs.joinmastodon.org/methods/streaming/#events)
public enum EventContent: Sendable, Equatable {
    /// A new post has appeared.
    case update(Post)
    /// The post with the associated ID has been deleted.
    case delete(Post.ID)
    /// A new Notification has appeared.
    case notification(TootNotification)
    /// Keyword filters have been changed.
    case filtersChanged
    /// A direct conversation has been updated.
    case conversation(Conversation)
    /// An announcement has been published.
    case announcement(Announcement)
    /// An announcement has received an emoji reaction.
    case announcementReaction(AnnouncementReaction)
    /// The announcement with the associated ID has been deleted.
    case announcementDelete(Announcement.ID)
    /// A post has been edited.
    case postUpdate(Post)
    /// An encrypted message has been received.
    case encryptedMessage
    /// An event that TootSDK does not support has been received.
    case unsupportedEvent(event: String, payload: String?)

    // TODO: support Pleroma-specific event types described at https://docs-develop.pleroma.social/backend/development/API/differences_in_mastoapi_responses/#streaming
}

extension EventContent {
    /// Attempt to initialize from the "event" and "payload" properties of the JSON returned by the streaming server.
    internal init?(_ event: String, payload: String?) {
        switch event {
        case "update":
            guard let payloadData = payload?.data(using: .utf8),
                let post = try? TootDecoder().decode(Post.self, from: payloadData)
            else { return nil }
            self = .update(post)
        case "delete":
            guard let postID = payload else { return nil }
            self = .delete(postID)
        case "notification":
            guard let payloadData = payload?.data(using: .utf8),
                let notification = try? TootDecoder().decode(TootNotification.self, from: payloadData)
            else { return nil }
            self = .notification(notification)
        case "filters_changed":
            self = .filtersChanged
        case "conversation":
            guard let payloadData = payload?.data(using: .utf8),
                let conversation = try? TootDecoder().decode(Conversation.self, from: payloadData)
            else { return nil }
            self = .conversation(conversation)
        case "announcement":
            guard let payloadData = payload?.data(using: .utf8),
                let announcement = try? TootDecoder().decode(Announcement.self, from: payloadData)
            else { return nil }
            self = .announcement(announcement)
        case "announcement.reaction":
            guard let payloadData = payload?.data(using: .utf8),
                let reaction = try? TootDecoder().decode(AnnouncementReaction.self, from: payloadData)
            else { return nil }
            self = .announcementReaction(reaction)
        case "announcement.delete":
            guard let announcementID = payload else { return nil }
            self = .announcementDelete(announcementID)
        case "status.update":
            guard let payloadData = payload?.data(using: .utf8),
                let post = try? TootDecoder().decode(Post.self, from: payloadData)
            else { return nil }
            self = .postUpdate(post)
        case "encrypted_message":
            self = .encryptedMessage
        default:
            self = .unsupportedEvent(event: event, payload: payload)
        }
    }
}
