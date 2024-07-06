//
//  NodeInfo.swift
//
//
//  Created by Łukasz Rutkowski on 06/07/2024.
//

import Foundation

public struct NodeInfo: Codable {
    public let software: Software

    public struct Software: Codable {
        public let name: String
        public let version: String
    }
}

public struct WellKnownNodeInfo: Codable {
    public let links: [Link]

    public var nodeInfo: String? {
        let nodeInfoRelations = [
            "http://nodeinfo.diaspora.software/ns/schema/1.0",
            "http://nodeinfo.diaspora.software/ns/schema/1.1",
            "http://nodeinfo.diaspora.software/ns/schema/2.0",
            "http://nodeinfo.diaspora.software/ns/schema/2.1",
        ]
        return links.first { nodeInfoRelations.contains($0.rel) }?.href
    }

    public struct Link: Codable {
        public let rel: String
        public let href: String
    }
}

extension NodeInfo {
    public var flavour: TootSDKFlavour {
        if software.name == "pleroma" {
            return .pleroma
        }
        if software.name == "pixelfed" {
            return .pixelfed
        }
        if software.name == "friendica" {
            return .friendica
        }
        if software.name == "akkoma" {
            return .akkoma
        }
        if software.name == "firefish" || software.name == "catodon" || software.name == "iceshrimp" {
            return .firefish
        }
        if software.name == "sharkey" {
            return .sharkey
        }
        return .mastodon
    }
}
