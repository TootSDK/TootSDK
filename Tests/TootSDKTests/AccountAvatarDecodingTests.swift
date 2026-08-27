import Foundation
import Testing

@testable import TootSDK

struct AccountAvatarDecodingTests {
    @Test func postDecodesWhenAccountAvatarURLsAreMissing() throws {
        let fixture = localContent("post no emojis")
        var post = try #require(JSONSerialization.jsonObject(with: fixture) as? [String: Any])
        var account = try #require(post["account"] as? [String: Any])
        account.removeValue(forKey: "avatar")
        account.removeValue(forKey: "avatar_static")
        post["account"] = account

        let data = try JSONSerialization.data(withJSONObject: post)
        let decodedPost = try TootDecoder().decode(Post.self, from: data)

        #expect(decodedPost.account.avatar == nil)
        #expect(decodedPost.account.avatarStatic == nil)
    }
}
