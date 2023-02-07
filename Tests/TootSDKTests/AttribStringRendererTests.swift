// Created by konstantin on 06/01/2023.
// Copyright (c) 2023. All rights reserved.
#if canImport(UIKit) || canImport(AppKit)
import XCTest
@testable import TootSDK

@available(watchOS 8, *)
@available(iOS 15, *)
final class AttribStringRendererTests: XCTestCase {
    let serverUrl: String = "https://m.iamkonstantin.eu"
    
#if canImport(UIKit)
        let renderer = UIKitAttribStringRenderer()
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
        let renderer = AppKitAttribStringRenderer()
#else
    let renderer = UniversalRenderer()
#endif
        
    func testRendersPostWithoutEmojisPlainString() throws {

        // arrange
        let post = try localObject(Post.self, "post no emojis")
        let expected = try NSMutableAttributedString(markdown: """
Hey fellow #Swift devs 👋!

As some of you may know, @konstantin and @davidgarywood have been working on an open-source swift package library designed to help other devs make apps that interact with the fediverse (like Mastodon, Pleroma, Pixelfed etc). We call it TootSDK ✨!

The main purpose of TootSDK is to take care of the “boring” and complicated parts of the Mastodon API, so you can focus on crafting the actual app experience.
""", options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        
        // act
        let rendered = renderer.render(post)
        
        // assert
        XCTAssertEqual(rendered.attributedString.string, expected.string)
    }
    
    func testRendersPostWithoutEmojisLinks() throws {
        // arrange
        let post = try localObject(Post.self, "post no emojis")
        
        let expectedParsedString = try NSMutableAttributedString(markdown: """
Hey fellow [#Swift](https://iosdev.space/tags/Swift) devs 👋!

As some of you may know, [@konstantin](https://m.iamkonstantin.eu/users/konstantin) and [@davidgarywood](https://social.davidgarywood.com/davidgarywood) have been working on an open-source swift package library designed to help other devs make apps that interact with the fediverse (like Mastodon, Pleroma, Pixelfed etc). We call it TootSDK ✨!

The main purpose of TootSDK is to take care of the “boring” and complicated parts of the Mastodon API, so you can focus on crafting the actual app experience.
""", options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        let expectedString =
"""
Hey fellow #Swift devs 👋!
As some of you may know, @konstantin and @davidgarywood have been working on an open-source swift package library designed to help other devs make apps that interact with the fediverse (like Mastodon, Pleroma, Pixelfed etc). We call it TootSDK ✨!
The main purpose of TootSDK is to take care of the “boring” and complicated parts of the Mastodon API, so you can focus on crafting the actual app experience.

"""
        
        // just a sanity check on the expected mutable string
        // we only want to see links being rendered here
        var expectedAttributes = 0
        expectedParsedString.enumerateAttributes(in: NSRange(0..<expectedParsedString.length), options: .longestEffectiveRangeNotRequired, using: {(value: [NSAttributedString.Key : Any], range, stop) in
            
            for attr in value {
                expectedAttributes += 1
                XCTAssert(attr.key == .link)
            }
        })
        XCTAssertEqual(expectedAttributes, 3)
        
        
        // act
        let content = renderer.render(post)
        let rendered = content.attributedString
        
        
        // assert
        var renderedAttributes = 0
        rendered.enumerateAttributes(in: NSRange(0..<rendered.length), options: .longestEffectiveRangeNotRequired, using: {(value: [NSAttributedString.Key : Any], range, stop) in
            print(value)
            for attr in value {
                renderedAttributes += 1
                XCTAssertEqual(attr.key, .link)
            }
        })
        XCTAssertEqual(renderedAttributes, 3)
        
        XCTAssertEqual(content.string, expectedString)
    }
    
    
    func testRendersPostWithEmojisPlainString() throws {
        // arrange
        let post = try localObject(Post.self, "post with emojis and attachments")
        let expectedParsedString = try NSMutableAttributedString(markdown: """
I just #love #coffee :heart_cup There is no better way to start the day.
""", options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        let expectedString = """
I just #love #coffee There is no better way to start the day.
"""
        
        // act
        let rendered = renderer.render(post)
        
        // assert
        XCTAssertEqual(rendered.attributedString.string, expectedParsedString.string)
        XCTAssertEqual(rendered.string, expectedString)
    }
    
    
    func testParagraphsToLinebreaks() throws {
        // Arrange
        let post = try localObject(Post.self, "post wordle linebreaks")
        
        let expectedString: String = """
Wordle 591 X/6*
🟨⬛🟩🟨⬛
🟨⬛🟩⬛🟩
🟩🟩🟩⬛🟩
🟩🟩🟩⬛🟩
🟩🟩🟩⬛🟩
🟩🟩🟩⬛🟩

"""
        
        // act
        let rendered = renderer.render(post)
        
        // Assert
        XCTAssertEqual(rendered.string, expectedString)
    }
}
#endif
