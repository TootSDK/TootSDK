// Created by konstantin on 17/12/2022.
// Copyright (c) 2022. All rights reserved.

import Foundation

public enum TootSDKFlavour: String, Codable, Sendable, CaseIterable {
    /// Mastodon server. API Documentation can be found at https://docs.joinmastodon.org/api/
    case mastodon

    /// Pleroma server. API Documentation can be found at https://docs-develop.pleroma.social/backend/development/API/differences_in_mastoapi_responses/
    case pleroma

    /// Pixelfed server. API Documentation can be found at https://docs.pixelfed.org/technical-documentation/api/
    case pixelfed

    /// Friendica server. API Documentation can be found at https://github.com/friendica/friendica/blob/stable/doc/API-Mastodon.md
    case friendica

    /// Akkoma server. API Documentation can be found at https://docs.akkoma.dev/stable/development/API/differences_in_mastoapi_responses/
    case akkoma
}
