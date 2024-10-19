// Created by konstantin on 10/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension TootClient {
    /// Obtain general information about the server.
    public func getInstanceInfo() async throws -> any Instance {
		do {
			try requireFeature(.instancev2)
			return try await getInstanceV2()
		} catch TootSDKError.unsupportedFlavour(_, _) {
			return try await getInstanceV1()
		}
    }
	
	public func getInstanceV1() async throws -> InstanceV1 {
		let req = HTTPRequestBuilder {
			$0.url = getURL(["api", "v1", "instance"])
			$0.method = .get
		}
		return try await fetch(InstanceV1.self, req)
	}
	
	public func getInstanceV2() async throws -> InstanceV2 {
		let req = HTTPRequestBuilder {
			$0.url = getURL(["api", "v2", "instance"])
			$0.method = .get
		}
		return try await fetch(InstanceV2.self, req)
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

    /// Get node info.
    public func getNodeInfo() async throws -> NodeInfo {
        let wellKnownReq = HTTPRequestBuilder {
            $0.url = getURL([".well-known", "nodeinfo"])
            $0.method = .get
        }
        let wellKnown = try await fetch(WellKnownNodeInfo.self, wellKnownReq)
        guard let nodeInfo = wellKnown.nodeInfo else {
            throw TootSDKError.nodeInfoUnsupported
        }
        let req = HTTPRequestBuilder {
            $0.url = URL(string: nodeInfo)
            $0.method = .get
        }
        return try await fetch(NodeInfo.self, req)
    }
}

extension TootFeature {

    /// Ability to retrieve instance extended descriptions
    ///
    public static let extendedDescription = TootFeature(supportedFlavours: [.mastodon])
}
