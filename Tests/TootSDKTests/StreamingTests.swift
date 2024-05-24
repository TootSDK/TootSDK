//
//  StreamingTests.swift
//
//
//  Created by Dale Price on 5/23/24.
//

import XCTest

@testable import TootSDK

final class StreamingTests: XCTestCase {
    func testDecodingUpdate() throws {
        // arrange
        let json = localContent("streaming_update")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(StreamingEvent.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
		XCTAssertEqual(result.timeline, .publicTimeline)
        guard case .update(let post) = result.event else {
            XCTFail("Event payload is not of expected type.")
            return
        }
        XCTAssertEqual(post.id, "108913983692647032")
    }
    
    func testDecodingDelete() throws {
        // arrange
        let json = localContent("streaming_delete")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(StreamingEvent.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.timeline, .publicTimeline)
        guard case .delete(let postID) = result.event else {
            XCTFail("Event payload is not of expected type.")
            return
        }
        XCTAssertEqual(postID, "106692867363994015")
    }
    
    func testDecodingFiltersChanged() throws {
        // arrange
        let json = localContent("streaming_filters_changed")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(StreamingEvent.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.timeline, .user)
        XCTAssertEqual(result.event, .filtersChanged)
    }
}
