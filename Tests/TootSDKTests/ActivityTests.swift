//
//  ActivityTests.swift
//  
//
//  Created by konstantin on 30/10/2022.
//

import XCTest
@testable import TootSDK

final class ActivityTests: XCTestCase {
    
    private func getExampleDate() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = DateComponents(year: 2019, month: 11, day: 25, hour: 0, minute: 0, second: 0)
        return calendar.date(from: components)!
    }
    
    func testDecoding() throws {
        // arrange
        let json = localContent("activity")
        let decoder = TootDecoder()
        let weekDate = getExampleDate()
        
        
        // act
        let result = try decoder.decode(Activity.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.week, weekDate)
    }
    
    func testEncoding() throws {
        // arrange
        let json = localContent("activity")
        let decoder = TootDecoder()
        let encoder = TootEncoder()
        let model = try decoder.decode(Activity.self, from: json)
        
        // act
        let encodedData = try encoder.encode(model)
        let encodedModel = try decoder.decode(Activity.self, from: encodedData)
        
        // assert
        XCTAssertNotNil(encodedModel)
        XCTAssertEqual(encodedModel, model)
    }
}

