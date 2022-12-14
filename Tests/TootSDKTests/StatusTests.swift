// Created by konstantin on 04/12/2022.
// Copyright (c) 2022. All rights reserved.


import XCTest
@testable import TootSDK

final class StatusTests: XCTestCase {
    func testScheduledStatusValidatesScheduledAtRequired() throws {
        // arrange
        let params = ScheduledStatusParams(mediaIds: [], visibility: .public)
        
        // act
        XCTAssertThrowsError(try ScheduledStatusRequest(from: params)) {error in
            XCTAssertEqual(error as? TootSDKError, TootSDKError.missingParameter(parameterName: "scheduledAt"))
        }
    }
    
    func testScheduledStatusValidatesScheduledAtTooSoon() throws {
        // arrange
        var params = ScheduledStatusParams(mediaIds: [], visibility: .public)
        params.scheduledAt = Date().addingTimeInterval(TimeInterval(4.5 * 60.0)) // date is only 5 mins in the future
        
        // act
        XCTAssertThrowsError(try ScheduledStatusRequest(from: params)) {error in
            XCTAssertEqual(error as? TootSDKError, TootSDKError.invalidParameter(parameterName: "scheduledAt"))
        }
    }
    
    func testScheduledStatusValidatesScheduledAtInTheFuture() throws {
        // arrange
        var params = ScheduledStatusParams(mediaIds: [], visibility: .public)
        params.scheduledAt = Date().addingTimeInterval(TimeInterval(6.0 * 60.0)) // date is only 5 mins in the future
        
        // act
        XCTAssertNoThrow(try ScheduledStatusRequest(from: params))
    }
}
