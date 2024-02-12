// Created by konstantin on 10/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension TootClient {
    /// Obtain general information about the server
    public func getInstanceInfo() async throws -> Instance {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance"])
            $0.method = .get
        }
        return try await fetch(Instance.self, req)
    }

    public func getInstanceRules() async throws -> [InstanceRule] {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "rules"])
            $0.method = .get
        }
        return try await fetch([InstanceRule].self, req)
    }

    /// Obtain an extended description of this server
    public func getExtendedDescription() async throws -> ExtendedDescription {
        try requireFeature(.extendedDescription)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "extended_description"])
            $0.method = .get
        }
        return try await fetch(ExtendedDescription.self, req)
    }

    /// Translation language pairs supported by the translation engine used by the server.
    public func getTranslationLanguages() async throws -> [String: [String]] {
        try requireFeature(.translatePost)
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance", "translation_languages"])
            $0.method = .get
        }
        return try await fetch([String: [String]].self, req)
    }
}

extension TootFeature {

    /// Ability to retrieve instance extended descriptions
    ///
    public static let extendedDescription = TootFeature(supportedFlavours: [.mastodon])
}
