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

        private let htmlWithSpecialMarkup =
            #"<p class="quote-inline">RE: <a href="https://example.com/post/1234" rel="nofollow noopener" translate="no" target="_blank"><span class="invisible">https://</span><span class="ellipsis">example.com/post/1</span><span class="invisible">234</span></a></p><p>Hello world</p>"#

        @Test func htmlWithInlineQuoteSkipped() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let renderedDefault = renderer.render(html: htmlWithSpecialMarkup, options: .skipInlineQuotes)
            #expect(renderedDefault.rawString == htmlWithSpecialMarkup)
            #expect(renderedDefault.plainString == "Hello world")
            #expect(renderedDefault.attributedString == AttributedString("Hello world"))
        }

        @Test func htmlWithInlineQuotePreserved() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let renderedDefault = renderer.render(html: htmlWithSpecialMarkup)
            #expect(renderedDefault.rawString == htmlWithSpecialMarkup)
            #expect(
                renderedDefault.plainString == """
                    RE: https://example.com/post/1234

                    Hello world
                    """)
            let attributedString = try AttributedString(
                markdown: "RE: [https://example.com/post/1234](https://example.com/post/1234)\n\nHello world",
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            #expect(renderedDefault.attributedString == attributedString)
        }

        @Test func htmlWithInvisiblesSkipped() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let renderedDefault = renderer.render(html: htmlWithSpecialMarkup, options: .skipInvisibles)
            #expect(renderedDefault.rawString == htmlWithSpecialMarkup)
            #expect(
                renderedDefault.plainString == """
                    RE: example.com/post/1

                    Hello world
                    """)
            let attributedString = try AttributedString(
                markdown: "RE: [example.com/post/1](https://example.com/post/1234)\n\nHello world",
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            #expect(renderedDefault.attributedString == attributedString)
        }

        @Test func htmlWithEllipsisRendered() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let renderedDefault = renderer.render(html: htmlWithSpecialMarkup, options: .renderEllipsis)
            #expect(renderedDefault.rawString == htmlWithSpecialMarkup)
            #expect(
                renderedDefault.plainString == """
                    RE: https://example.com/post/1…234

                    Hello world
                    """)
            let attributedString = try AttributedString(
                markdown: "RE: [https://example.com/post/1…234](https://example.com/post/1234)\n\nHello world",
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            #expect(renderedDefault.attributedString == attributedString)
        }

        @Test func htmlWithShortenedLinks() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let renderedDefault = renderer.render(html: htmlWithSpecialMarkup, options: .shortenLinks)
            #expect(renderedDefault.rawString == htmlWithSpecialMarkup)
            #expect(
                renderedDefault.plainString == """
                    RE: example.com/post/1…

                    Hello world
                    """)
            let attributedString = try AttributedString(
                markdown: "RE: [example.com/post/1…](https://example.com/post/1234)\n\nHello world",
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            #expect(renderedDefault.attributedString == attributedString)
        }

        @Test func htmlWithSingleLevelBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = """
                <blockquote>
                    <p>Single level</p>
                    <p>Second paragraph</p>
                </blockquote>
                <p>Regular text</p>
                """
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	Single level
                    ┃	Second paragraph
                    Regular text
                    """)
        }

        @Test func htmlWithBlockQuoteBasicRendering() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Quoted text</p></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "┃\tQuoted text")
            // All text content inside a blockquote is emphasised; the ┃ prefix gutter is not.
            let quotedRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Quoted text")
            })
            #expect(quotedRun?.inlinePresentationIntent?.contains(.emphasized) == true)
        }

        @Test func htmlWithMultipleParagraphsInBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>First</p><p>Second</p><p>Third</p></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	First
                    ┃	Second
                    ┃	Third
                    """)
        }

        @Test func htmlWithNestedBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html =
                "<blockquote><p>Level one</p><blockquote><p>Level two</p></blockquote></blockquote><p>Regular text</p>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	Level one
                    ┃	┃	Level two
                    Regular text
                    """)
        }

        @Test func htmlWithTriplyNestedBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html =
                "<blockquote><p>Level one</p><blockquote><p>Level two</p><blockquote><p>Level three</p></blockquote></blockquote></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	Level one
                    ┃	┃	Level two
                    ┃	┃	┃	Level three
                    """)
        }

        @Test func htmlWithBlockQuoteContainingEmphasis() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p><em>Emphasized text</em></p></blockquote><p>Regular</p>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	Emphasized text
                    Regular
                    """)
            let emphasizedRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Emphasized text")
            })
            #expect(emphasizedRun?.inlinePresentationIntent?.contains(.emphasized) == true)
        }

        @Test func htmlWithBlockQuoteContainingBold() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p><strong>Bold text</strong></p></blockquote><p>Regular</p>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	Bold text
                    Regular
                    """)
            let boldRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Bold text")
            })
            // Blockquote adds .emphasized; <strong> adds .stronglyEmphasized on top.
            #expect(boldRun?.inlinePresentationIntent?.contains(.emphasized) == true)
            #expect(boldRun?.inlinePresentationIntent?.contains(.stronglyEmphasized) == true)
        }

        @Test func htmlWithBlockQuoteContainingList() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html =
                "<blockquote><ul><li>Item one</li><li>Item two</li></ul></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	 •	Item one
                    ┃	 •	Item two
                    """)
        }

        @Test func htmlWithBrOutsideBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<p>Line one<br>Line two</p>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    Line one
                    Line two
                    """)
        }

        @Test func htmlWithBrInBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Line one<br>Line two</p></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	Line one
                    ┃	Line two
                    """)
        }

        @Test func htmlWithMultipleBrInBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>First<br>Second<br>Third</p></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	First
                    ┃	Second
                    ┃	Third
                    """)
        }

        @Test func htmlWithBrInNestedBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><blockquote><p>Line one<br>Line two</p></blockquote></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == """
                    ┃	┃	Line one
                    ┃	┃	Line two
                    """)
        }

        @Test func htmlWithBlockQuoteContainingPartialEmphasis() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            // Only the middle word is wrapped in <em>, but blockquote emphasises all content uniformly.
            let html = "<blockquote><p>Normal <em>italic</em> text</p></blockquote>"
            let rendered = renderer.render(html: html)
            #expect(rendered.rawString == html)
            // Every content run — not just the <em> span — carries .emphasized.
            #expect(rendered.plainString == "┃\tNormal italic text")
            let normalRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Normal")
            })
            let italicRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("italic")
            })
            #expect(normalRun?.inlinePresentationIntent?.contains(.emphasized) == true)
            #expect(italicRun?.inlinePresentationIntent?.contains(.emphasized) == true)
        }
    }
#endif
