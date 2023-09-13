//
//  FamiliarFollowersTests.swift
//  
//
//  Created by Philip Chu on 9/1/23.
//

import XCTest
@testable import TootSDK

final class FamiliarFollowersTests: XCTestCase {
    
    func testFamiliarFollowersNoFollowersDecode() throws {
        // arrange
        let json = localContent("familiar_followers_nofollowers")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(FamiliarFollowers.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "110466616420795968")
        XCTAssertNotNil(result.accounts)
        XCTAssertEqual(result.accounts, [])
    }
}
