//
//  Test.swift
//  TootSDK
//
//  Created by Łukasz Rutkowski on 06/11/2024.
//

#if canImport(UIKit) || canImport(AppKit)
    import Foundation
    import Testing
    import TootSDK

    @Suite struct AttributedStringRendererTests {

        @Test func testRendersPostWithoutEmojis() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let post = try localObject(Post.self, "post no emojis")
            let plainString = """
                Hey fellow #Swift devs 👋!

                As some of you may know, @konstantin and @davidgarywood have been working on an open-source swift package library designed to help other devs make apps that interact with the fediverse (like Mastodon, Pleroma, Pixelfed etc). We call it TootSDK ✨!

                The main purpose of TootSDK is to take care of the “boring” and complicated parts of the Mastodon API, so you can focus on crafting the actual app experience.
                """
            let attributedString = try AttributedString(
                markdown: """
                    Hey fellow [#Swift](https://iosdev.space/tags/Swift) devs 👋!

                    As some of you may know, [@konstantin](https://m.iamkonstantin.eu/users/konstantin) and [@davidgarywood](https://social.davidgarywood.com/@davidgarywood) have been working on an open-source swift package library designed to help other devs make apps that interact with the fediverse (like Mastodon, Pleroma, Pixelfed etc). We call it TootSDK ✨!

                    The main purpose of TootSDK is to take care of the “boring” and complicated parts of the Mastodon API, so you can focus on crafting the actual app experience.
                    """,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )

            let rendered = AttributedStringRenderer().render(html: post.content ?? "")

            #expect(rendered.rawString == post.content)
            #expect(rendered.plainString == plainString)
            #expect(rendered.attributedString == attributedString)
        }

        @Test func testRendersPostWithEmojis() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let post = try localObject(Post.self, "post with emojis and attachments")
            let plainString = """
                I just #love #coffee :heart_cup:  There is no better way to start the day.
                """
            let attributedString = try AttributedString(
                markdown: """
                    I just [#love](https://m.iamkonstantin.eu/tag/love) [#coffee](https://m.iamkonstantin.eu/tag/coffee) :heart_cup:  There is no better way to start the day.
                    """,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )

            let rendered = AttributedStringRenderer().render(html: post.content ?? "")

            #expect(rendered.rawString == post.content)
            #expect(rendered.plainString == plainString)
            #expect(rendered.attributedString == attributedString)
        }

        @Test func testParagraphsToLineBreaks() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let post = try localObject(Post.self, "post wordle linebreaks")
            let plainString = """
                Wordle 591 X/6*

                🟨⬛🟩🟨⬛
                🟨⬛🟩⬛🟩
                🟩🟩🟩⬛🟩
                🟩🟩🟩⬛🟩
                🟩🟩🟩⬛🟩
                🟩🟩🟩⬛🟩
                """
            let attributedString = try AttributedString(
                markdown: plainString,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )

            let rendered = AttributedStringRenderer().render(html: post.content ?? "")

            #expect(rendered.rawString == post.content)
            #expect(rendered.plainString == plainString)
            #expect(rendered.attributedString == attributedString)
        }
    }
#endif
