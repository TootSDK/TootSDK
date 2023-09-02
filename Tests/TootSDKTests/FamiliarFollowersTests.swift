//
//  FamiliarFollowersTests.swift
//  
//
//  Created by Philip Chu on 9/1/23.
//

import XCTest
@testable import TootSDK

final class FamiliarFollowersTests: XCTestCase {
    
    func testFamiliarFollowersDecode() throws {
        // arrange
        let json = localContent("familiar_followers")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(FamiliarFollowers.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "109824850256644069")
        XCTAssertNotNil(result.accounts)
    }
}
