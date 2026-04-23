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

    #if canImport(UIKit)
        import UIKit

        typealias _TestFont = UIFont
        typealias _TestColor = UIColor
    #elseif canImport(AppKit)
        import AppKit

        typealias _TestFont = NSFont
        typealias _TestColor = NSColor
    #endif

    @Suite struct AttributedStringRendererTests {

        @Test func testRendersPostWithoutEmojis() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let post = try localObject(Post.self, "post no emojis")
            let plainString = """
                Hey fellow #Swift devs 👋!

                As some of you may know, @konstantin and @davidgarywood have been working on an open-source swift package library designed to help other devs make apps that interact with the fediverse (like Mastodon, Pleroma, Pixelfed etc). We call it TootSDK ✨!

                The main purpose of TootSDK is to take care of the \u{201C}boring\u{201D} and complicated parts of the Mastodon API, so you can focus on crafting the actual app experience.
                """
            let attributedString = try AttributedString(
                markdown: """
                    Hey fellow [#Swift](https://iosdev.space/tags/Swift) devs 👋!

                    As some of you may know, [@konstantin](https://m.iamkonstantin.eu/users/konstantin) and [@davidgarywood](https://social.davidgarywood.com/@davidgarywood) have been working on an open-source swift package library designed to help other devs make apps that interact with the fediverse (like Mastodon, Pleroma, Pixelfed etc). We call it TootSDK ✨!

                    The main purpose of TootSDK is to take care of the \u{201C}boring\u{201D} and complicated parts of the Mastodon API, so you can focus on crafting the actual app experience.
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

        private let enUS = BlockQuoteStyle(locale: Locale(identifier: "en_US"))

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
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == "\u{201C}Single level\nSecond paragraph\u{201D}\nRegular text")
        }

        @Test func htmlWithBlockQuoteBasicRendering() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Quoted text</p></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}Quoted text\u{201D}")
        }

        @Test func htmlWithMultipleParagraphsInBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>First</p><p>Second</p><p>Third</p></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}First\nSecond\nThird\u{201D}")
        }

        @Test func htmlWithNestedBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html =
                "<blockquote><p>Level one</p><blockquote><p>Level two</p></blockquote></blockquote><p>Regular text</p>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString == "\u{201C}Level one\n\u{2018}Level two\u{2019}\u{201D}\nRegular text")
        }

        @Test func htmlWithTriplyNestedBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html =
                "<blockquote><p>Level one</p><blockquote><p>Level two</p><blockquote><p>Level three</p></blockquote></blockquote></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(
                rendered.plainString
                    == "\u{201C}Level one\n\u{2018}Level two\n\u{201C}Level three\u{201D}\u{2019}\u{201D}")
        }

        @Test func htmlWithBlockQuoteContainingEmphasis() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p><em>Emphasized text</em></p></blockquote><p>Regular</p>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}Emphasized text\u{201D}\nRegular")
            let emphasizedRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Emphasized text")
            })
            #expect(emphasizedRun?.inlinePresentationIntent?.contains(.emphasized) == true)
        }

        @Test func htmlWithBlockQuoteContainingBold() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p><strong>Bold text</strong></p></blockquote><p>Regular</p>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}Bold text\u{201D}\nRegular")
            let boldRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Bold text")
            })
            #expect(boldRun?.inlinePresentationIntent?.contains(.stronglyEmphasized) == true)
        }

        @Test func htmlWithBlockQuoteContainingList() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html =
                "<blockquote><ul><li>Item one</li><li>Item two</li></ul></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C} \u{2022}\tItem one\n \u{2022}\tItem two\u{201D}")
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
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}Line one\nLine two\u{201D}")
        }

        @Test func htmlWithMultipleBrInBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>First<br>Second<br>Third</p></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}First\nSecond\nThird\u{201D}")
        }

        @Test func htmlWithBrInNestedBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><blockquote><p>Line one<br>Line two</p></blockquote></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}\u{2018}Line one\nLine two\u{2019}\u{201D}")
        }

        @Test func htmlWithBlockQuoteContainingPartialEmphasis() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Normal <em>italic</em> text</p></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "\u{201C}Normal italic text\u{201D}")
            let italicRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("italic")
            })
            #expect(italicRun?.inlinePresentationIntent?.contains(.emphasized) == true)
        }

        @Test func htmlWithEmptyBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.rawString == html)
            #expect(rendered.plainString == "")
        }

        // MARK: - Locale tests

        @Test func htmlWithFrenchBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Bonjour</p></blockquote>"
            let style = BlockQuoteStyle(locale: Locale(identifier: "fr_FR"))
            let rendered = renderer.render(html: html, blockQuoteStyle: style)
            #expect(rendered.plainString == "\u{AB}\u{00A0}Bonjour\u{00A0}\u{BB}")
        }

        @Test func htmlWithGermanBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Hallo</p></blockquote>"
            let style = BlockQuoteStyle(locale: Locale(identifier: "de_DE"))
            let rendered = renderer.render(html: html, blockQuoteStyle: style)
            #expect(rendered.plainString == "\u{201E}Hallo\u{201C}")
        }

        @Test func htmlWithJapaneseBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>こんにちは</p></blockquote>"
            let style = BlockQuoteStyle(locale: Locale(identifier: "ja_JP"))
            let rendered = renderer.render(html: html, blockQuoteStyle: style)
            #expect(rendered.plainString == "\u{300C}こんにちは\u{300D}")
        }

        @Test func htmlWithArabicBlockQuote() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>مرحبا</p></blockquote>"
            let style = BlockQuoteStyle(locale: Locale(identifier: "ar_SA"))
            let rendered = renderer.render(html: html, blockQuoteStyle: style)
            let plain = rendered.plainString
            #expect(plain.contains("مرحبا"))
            let hasQuoteMarks = !plain.hasPrefix("مرحبا")
            #expect(hasQuoteMarks)
        }

        @Test func htmlWithNestedBlockQuoteAlternation() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><blockquote><p>inner</p></blockquote></blockquote>"
            let rendered = renderer.render(html: html, blockQuoteStyle: enUS)
            #expect(rendered.plainString == "\u{201C}\u{2018}inner\u{2019}\u{201D}")
        }

        // MARK: - BlockQuoteStyle attribute tests

        @Test func htmlWithMarkAttributesAppliedToGlyphsOnly() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Body text</p></blockquote>"
            var markAttrs = AttributeContainer()
            #if canImport(UIKit)
            markAttrs.uiKit.foregroundColor = _TestColor.red
            #elseif canImport(AppKit)
            markAttrs.appKit.foregroundColor = _TestColor.red
            #endif
            let style = BlockQuoteStyle(
                locale: Locale(identifier: "en_US"),
                markAttributes: markAttrs
            )
            let rendered = renderer.render(html: html, blockQuoteStyle: style)

            let openRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters) == "\u{201C}"
            })
            let closeRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters) == "\u{201D}"
            })
            let bodyRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Body text")
            })

            #if canImport(UIKit)
            #expect(openRun?.uiKit.foregroundColor == _TestColor.red)
            #expect(closeRun?.uiKit.foregroundColor == _TestColor.red)
            #expect(bodyRun?.uiKit.foregroundColor != _TestColor.red)
            #elseif canImport(AppKit)
            #expect(openRun?.appKit.foregroundColor == _TestColor.red)
            #expect(closeRun?.appKit.foregroundColor == _TestColor.red)
            #expect(bodyRun?.appKit.foregroundColor != _TestColor.red)
            #endif
        }

        @Test func htmlWithContentAttributesFontAppliedToBody() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let renderer = AttributedStringRenderer()
            let html = "<blockquote><p>Normal <strong>bold</strong> text</p></blockquote>"
            let bodyFont = _TestFont.systemFont(ofSize: 14)
            var contentAttrs = AttributeContainer()
            #if canImport(UIKit)
            contentAttrs.uiKit.font = bodyFont
            #elseif canImport(AppKit)
            contentAttrs.appKit.font = bodyFont
            #endif
            let style = BlockQuoteStyle(
                locale: Locale(identifier: "en_US"),
                contentAttributes: contentAttrs
            )
            let rendered = renderer.render(html: html, blockQuoteStyle: style)

            let normalRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("Normal")
            })
            let boldRun = rendered.attributedString.runs.first(where: {
                String(rendered.attributedString[$0.range].characters).contains("bold")
            })

            #if canImport(UIKit)
            #expect(normalRun?.uiKit.font == bodyFont)
            #elseif canImport(AppKit)
            #expect(normalRun?.appKit.font == bodyFont)
            #endif
            #expect(boldRun?.inlinePresentationIntent?.contains(.stronglyEmphasized) == true)
        }

        // MARK: - inlineQuotation helper tests

        @Test func inlineQuotationEnglishDefault() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let result = AttributedString.inlineQuotation("hello", locale: Locale(identifier: "en_US"))
            #expect(String(result.characters) == "\u{201C}hello\u{201D}")
        }

        @Test func inlineQuotationLevel1Alternation() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let result = AttributedString.inlineQuotation("hello", level: 1, locale: Locale(identifier: "en_US"))
            #expect(String(result.characters) == "\u{2018}hello\u{2019}")
        }

        @Test func inlineQuotationFrenchNBSP() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let result = AttributedString.inlineQuotation("bonjour", locale: Locale(identifier: "fr_FR"))
            #expect(String(result.characters) == "\u{AB}\u{00A0}bonjour\u{00A0}\u{BB}")
        }

        @Test func inlineQuotationAttributedStringOverload() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            var content = AttributedString("hello")
            content.inlinePresentationIntent = .emphasized
            let result = AttributedString.inlineQuotation(content, locale: Locale(identifier: "en_US"))
            #expect(String(result.characters) == "\u{201C}hello\u{201D}")
            let run = result.runs.first(where: {
                String(result[$0.range].characters) == "hello"
            })
            #expect(run?.inlinePresentationIntent?.contains(.emphasized) == true)
        }

        @Test func inlineQuotationStringOverload() async throws {
            guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
            let result = AttributedString.inlineQuotation("world", locale: Locale(identifier: "en_US"))
            #expect(String(result.characters) == "\u{201C}world\u{201D}")
        }
    }
#endif
