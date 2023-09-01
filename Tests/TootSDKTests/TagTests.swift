//
//  TagTests.swift
//  
//
//  Created by Philip Chu on 8/20/23.
//

import XCTest
@testable import TootSDK

final class TagTests: XCTestCase {
    
    func testTagDecode() throws {
        // arrange
        let json = localContent("tag")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(Tag.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "tootsdk")
        XCTAssertEqual(result.following, false)
        XCTAssertNotNil(result.history)
    }
    
    func testFeaturedTagDecode() throws {
        // arrange
        let json = localContent("featured_tag")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(FeaturedTag.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "tootsdk")
        XCTAssertEqual(result.id, "384027")
        XCTAssertNotNil(result.lastPostAt)
    }
    
    func testUnusedFeaturedTagDecode() throws {
        // arrange
        let json = localContent("featured_tag_unused")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(FeaturedTag.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Mandalorian")
        XCTAssertEqual(result.id, "527787")
        XCTAssertNil(result.lastPostAt)
    }
    
    
}

