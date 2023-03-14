import ArgumentParser
import Foundation
import TootSDK
import FeedKit
import SwiftSoup

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct SocialAccount: Codable {
    var url: String
    var provider: String
}

struct MakePost: AsyncParsableCommand {
    
    @Option(name: .short, help: "URL to the instance to connect to make the post to")
    var url: String
    
    @Option(name: .short, help: "Access token for an account with sufficient permissions.")
    var token: String
    
    private var feedURL = "https://github.com/tootsdk/tootsdk/releases.atom"
    
    private var urlSession: URLSession {
        URLSession(configuration: URLSessionConfiguration.default )
    }
    
    private var maintainers: [String] = ["kkostov", "davidgarywood"]
    
    mutating func run() async throws {
        guard let postParams = try await getRelease() else { return }
        
        let client = try await TootClient(connect: URL(string: url)!, accessToken: token)

        do {
            let post = try await client.publishPost(postParams)
            print(post)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private mutating func getRelease() async throws -> PostParams? {
        guard
            let url = URL(string: feedURL),
            let (data, _ ) = try? await urlSession.getData(from: url)
        else {
            print("unable to retrieve releases atom feed")
            return nil
        }
        
        let parser = FeedParser(data: data)
        
        let result = parser.parse()
        
        switch result {
        case .success(let feed):
            if let entry = feed.atomFeed?.entries?.first {
                let tag = entry.title ?? ""
                let url = entry.links?.first?.attributes?.href ?? ""
                
                let changes = try await parseChanges(html: entry.content?.value ?? "")
                
                let params = createPost(tag: tag, releaseURL: url, changes: changes)
                return params
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private func parseChanges(html: String) async throws -> [String] {
        let changes = html.split(separator: "<li>")
        
        var changesToReturn: [String] = []
        
        for change in changes {
            if let changeLine = try await parseChange(change: String(change)) {
                changesToReturn.append(changeLine)
            }
        }
        
        return changesToReturn
    }
    
    private func parseChange(change: String) async throws -> String? {
        let titleHTML = try SwiftSoup.parse(change).body()?.text() ?? ""
        let title = titleHTML.split(separator: " by")
        
        if title.count > 1 {
            let title = String(title.first ?? "")
            let users = try await parseUsers(html: change)
            
            var userCredits: [String] = []
            
            for user in users {
                if let mastodonURL = try await getUserMastodon(user: user) {
                    userCredits.append(mastodonURL)
                } else {
                    userCredits.append("https://github.com/" + user)
                }
            }
            
            return title + " " + userCredits.joined(separator: ", ")
        } else {
            return nil
        }
    }
    
    private func parseUsers(html: String) async throws -> [String] {
        let usersHTML = try SwiftSoup.parse(html).getElementsByClass("user-mention")
        
        let users = try usersHTML.map({ user in
            try user.text().replacingOccurrences(of: "@", with: "")
        })
        
        let unique = Array(Set(users))
        
        return unique
    }
    
    private func getUserMastodon(user: String) async throws -> String? {
        let mastodonURL = "https://api.github.com/users/" + user + "/social_accounts"
        let (data, _ ) = try await urlSession.getData(from: URL(string: mastodonURL)!)
        
        let socialAccounts = try JSONDecoder().decode([SocialAccount].self, from: data)
        
        if let userMastodonURL = socialAccounts.first(where: { $0.provider == "mastodon" })?.url {
            
            let url = URL(string: userMastodonURL)!
            let pathURL = url.deletingLastPathComponent()

            let user = url.lastPathComponent
            let scheme = url.scheme ?? ""
            
            let path = pathURL.absoluteString.replacingOccurrences(of: scheme + "://", with: "").replacingOccurrences(of: "/", with: "")
            
            let mastodonUser = user + "@" + path
                        
            return mastodonUser
        } else {
            return nil
        }
    }
    
    /// Creates PostParams to create a post based on the inputs
    /// - Parameters:
    ///   - tag: the tag for the latest release in format X.X.X
    ///   - releaseURL: theURL to point to the latest release
    /// - Returns: TootSDK post params for a new post
    private func createPost(tag: String,
                            releaseURL: String,
                            changes: [String]) -> PostParams {
        
        let changes = changes.map({ change in
            return "- " + change
        })
        .joined(separator: "\n")
        
        let changeText = changes.isEmpty ? "" : changes + "\n\n"
                
        let text = "A new release of TootSDK - "
        + tag + " 📣 \n\n"
        + releaseURL + "\n\n"
        + "What's changed:" + "\n\n"
        
        + changeText
        
        + "We’d like to thank everyone who has submitted PRs, raised issues since we released the package publicly." + "\n\n"
        
        + "Community contributions are greatly appreciated 🙌" + "\n\n"
        
        + " #iOSDev #Swift #TootSDK #Fediverse"
        
        let params = PostParams(post: text, visibility: .public)
        return params
    }
    
}
