import Foundation

/// General information about an instance across all versions of the Instance API.
///
/// Contains properties that are common to both ``InstanceV1`` and ``InstanceV2``. Properties where there is a conflict between each version's implementation are left out of this protocol.
///
/// For example, in V1, `description` contains the extended description, but in V2 `description` contains the short description, so this is left out of the protocol. The idea here is that you can use this protocol's properties safely and predictably regardless of which version of the endpoint is used.
public protocol Instance: Codable, Hashable, Sendable {
	/// The domain name of the instance.
	var domain: String? { get }
	
	/// The title of the website.
	var title: String? { get }
	
	/// The version of the server installed on the instance.
	var version: String { get }
	
	/// Default version of banner image for the website.
	///
	/// Note that ``InstanceV2`` may contain multiple sizes of the image as well as additional metadata not included here.
	var thumbnailURL: String? { get }
	
	/// Primary languages of the website and its staff as ISO 639-1 two-letter codes.
	var languages: [String]? { get }
	
	var urls: InstanceConfiguration.URLs? { get }
	
	/// Configured values and limits for this instance.
	var configuration: InstanceConfiguration? { get }
	
	/// Whether registrations are enabled.
	var registrationsEnabled: Bool? { get }
	
	/// Whether registrations require moderator approval.
	var approvalRequired: Bool? { get }
	
	/// An email that may be contacted for any inquiries or issues.
	var email: String? { get }
	
	/// An account that can be contacted natively over the network regarding inquiries or issues.
	var contactAccount: Account? { get }
	
	/// An itemized list of rules for users of the instance.
	var rules: [InstanceRule]? { get }
}

extension Instance {
	public var flavour: TootSDKFlavour {
		// 2.7.2 (compatible; Pleroma 2.5.0)
		if version.lowercased().contains("pleroma") {
			return .pleroma
		}
		// 2.7.2 (compatible; Pixelfed 0.11.9)
		if version.lowercased().contains("pixelfed") {
			return .pixelfed
		}
		// 2.8.0 (compatible; Friendica 2023.05)
		if version.lowercased().contains("friendica") {
			return .friendica
		}
		// 2.7.2 (compatible; Akkoma 3.10.4-0-gebfb617)
		if version.lowercased().contains("akkoma") {
			return .akkoma
		}
		// 3.0.0 (compatible; Firefish 1.0.4-dev5)
		if version.lowercased().contains("firefish") {
			return .firefish
		}
		
		// 4.2.1 (compatible; Iceshrimp 2023.12-pre3)
		// 4.2.1 (compatible; Iceshrimp.NET/2024.1-beta2.security3+e1d25a9231)
		if version.lowercased().contains("iceshrimp") {
			return .iceshrimp
		}
		
		// 4.2.1 (compatible; Catodon 24.01-dev)
		if version.lowercased().contains("catodon") {
			return .catodon
		}
		
		// 3.0.0 (compatible; Sharkey 2023.12.0.beta3)
		if version.lowercased().contains("sharkey") {
			return .sharkey
		}
		return .mastodon
	}
}
