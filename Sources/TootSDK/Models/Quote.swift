//
//  Quote.swift
//  TootSDK
//
//  Created by Dale Price on 7/17/25.
//

import Foundation

/// Represents a quote or a quote placeholder, with the current authorization status.
public struct Quote: Codable, Sendable, Hashable {

    /// The state of a ``Quote``.
    public enum QuoteState: String, Codable, Hashable, Sendable {
        /// The quote has not been acknowledged by the quoted account yet, and requires authorization before being displayed.
        case pending
        /// The quote has been accepted and can be displayed. This is the one of the few cases where ``Quote/quotedPost`` is non-null.
        case accepted
        /// The quote has been explicitly rejected by the quoted account, and cannot be displayed.
        case rejected
        /// The quote has been previously accepted, but is now revoked, and thus cannot be displayed.
        case revoked
        /// The quote has been approved, but the quoted post itself has now been deleted.
        case deleted
        /// The quote has been approved, but cannot be displayed because the user is not authorized to see it.
        case unauthorized
        /// The quote has been approved, but should not be displayed because the user has blocked the account being quoted. This is the one of the few cases where ``Quote/quotedPost`` is non-null.
        case blockedAccount = "blocked_account"
        /// The quote has been approved, but should not be displayed because the user has blocked the domain of the account being quoted. This is the one of the few cases where ``Quote/quotedPost`` is non-null.
        case blockedDomain = "blocked_domain"
        /// The quote has been approved, but should not be displayed because the user has muted the the account being quoted. This is the one of the few cases where ``Quote/quotedPost`` is non-null.
        case mutedAccount = "muted_account"
    }

    /// A post being quoted.
    public enum QuotedContent: Codable, Hashable, Sendable {
        /// The full content of the ``Post`` being quoted.
        ///
        /// This is the value when Mastodon returns a [Quote](https://docs.joinmastodon.org/entities/Quote/) entity.
        case post(Post)
        /// The identifier of a post being quoted.
        ///
        /// This is the value when Mastodon returns a [ShallowQuote](https://docs.joinmastodon.org/entities/ShallowQuote/) entity.
        case postID(String)
    }

    /// The state of the quote.
    ///
    /// `nil` for flavors that don't provide a quote state.
    public var state: OpenEnum<QuoteState>?

    /// The status or status ID being quoted, if the quote has been accepted. On flavors that support ``state``, this is expected to be `nil`, unless the ``state`` is ``QuoteState/accepted``, ``QuoteState/blockedDomain``, ``QuoteState/blockedAccount``, or ``QuoteState/mutedAccount``.
    public var quotedPost: QuotedContent?

    enum CodingKeys: String, CodingKey {
        case state
        case quotedPost = "quotedStatus"
        case quotedPostID = "quotedStatusId"
    }

    /// Mastodon returns either a `Quote` entity containing the `quoted_status` property or `ShallowQuote` containing `quoted_status_id`, either of which may be nil, but `Quote` and `ShallowQuote` are otherwise identical. This handles decoding either one as a ``Quote`` struct.
    public init(from decoder: any Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state = try container.decode(OpenEnum<QuoteState>.self, forKey: .state)

            if let quotedPost = try container.decodeIfPresent(Post.self, forKey: .quotedPost) {
                self.quotedPost = .post(quotedPost)
            } else if let quotedPostID = try container.decodeIfPresent(String.self, forKey: .quotedPostID) {
                self.quotedPost = .postID(quotedPostID)
            } else {
                self.quotedPost = nil
            }
        } catch {
            // handle Akkoma-style quote post where a `Post` is used instead of a `Quote`
            let container = try decoder.singleValueContainer()
            let post = try container.decode(Post.self)
            state = nil
            quotedPost = .post(post)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(state?.rawValue, forKey: .state)
        switch quotedPost {
        case .post(let post):
            try container.encode(post, forKey: .quotedPost)
        case .postID(let id):
            try container.encode(id, forKey: .quotedPostID)
        case nil:
            break
        }
    }
}
