// Created by konstantin on 02/11/2022
// Copyright (c) 2022. All rights reserved.

import struct Foundation.Date

/// Represents a poll attached to a post.
public struct Poll: Codable, Hashable, Identifiable, Sendable {
    public init(
        id: String,
        expiresAt: Date? = nil,
        expired: Bool,
        multiple: Bool,
        votesCount: Int,
        votersCount: Int? = nil,
        voted: Bool? = nil,
        ownVotes: [Int]? = nil,
        options: [Poll.Option],
        emojis: [Emoji]
    ) {
        self.id = id
        self.expiresAt = expiresAt
        self.expired = expired
        self.multiple = multiple
        self.votesCount = votesCount
        self.votersCount = votersCount
        self.voted = voted
        self.ownVotes = ownVotes
        self.options = options
        self.emojis = emojis
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.expiresAt = try? container.decodeIfPresent(Date.self, forKey: .expiresAt)
        self.expired = try container.decode(Bool.self, forKey: .expired)
        self.multiple = try container.decode(Bool.self, forKey: .multiple)
        self.votesCount = try container.decode(Int.self, forKey: .votesCount)
        self.votersCount = try? container.decodeIfPresent(Int.self, forKey: .votersCount)
        self.voted = try? container.decodeIfPresent(Bool.self, forKey: .voted)
        self.ownVotes = try? container.decodeIfPresent([Int].self, forKey: .ownVotes)
        self.options = try container.decode([Option].self, forKey: .options)
        // firefish doesn't always return this
        self.emojis = (try? container.decode([Emoji].self, forKey: .emojis)) ?? []
    }

    /// The ID of the poll in the database.
    public var id: String
    /// When the poll ends.
    public var expiresAt: Date?
    ///  Is the poll currently expired?
    public var expired: Bool
    ///  Does the poll allow multiple-choice answers?
    public var multiple: Bool
    /// How many votes have been received.
    public var votesCount: Int
    /// How many unique accounts have voted on a multiple-choice poll.
    public var votersCount: Int?
    /// When called with a user token, has the authorized user voted?
    public var voted: Bool?
    /// When called with a user token, which options has the authorized user chosen?
    /// Contains an array of index values for options.
    public var ownVotes: [Int]?
    /// Possible answers for the poll.
    public var options: [Option]
    /// Custom emoji to be used for rendering poll options.
    public var emojis: [Emoji]

    public struct Option: Codable, Hashable, Sendable {
        public init(title: String, votesCount: Int) {
            self.title = title
            self.votesCount = votesCount
        }

        /// The text value of the poll option. String.
        public var title: String
        /// The number of received votes for this option. Number, or null if results are not published yet.
        public var votesCount: Int
    }
}
