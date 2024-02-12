// Created by konstantin on 05/11/2022.
// Copyright (c) 2022. All rights reserved.

import XCTest

@testable import TootSDK

final class PaginationTests: XCTestCase {
    let serverUrl: String = "https://m.iamkonstantin.eu"

    func testPaginationWithInvalidNextAndPrevious() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?max_id=420>; rel=\"\"",
            "this is not a valid URL; rel=\"next\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        XCTAssertNil(pagination.sinceId)
        XCTAssertNil(pagination.minId)
        XCTAssertNil(pagination.maxId)
    }

    func testPaginationWithValidNext() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?limit=42&max_id=420>; rel=\"next\"",
            "this is not a valid URL; rel=\"prev\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        XCTAssertNil(pagination.sinceId)
        XCTAssertNil(pagination.minId)
        XCTAssertEqual(pagination.maxId, "420")
    }

    func testPaginationWithValidPrevious() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?limit=42&since_id=420>; rel=\"prev\"",
            "this is not a valid URL; rel=\"next\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        XCTAssertEqual(pagination.sinceId, "420")
        XCTAssertNil(pagination.minId)
        XCTAssertNil(pagination.maxId, "420")
    }

    func testPaginationWithValidNextAndPrevious() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?limit=42&since_id=123>; rel=\"prev\"",
            "<\(serverUrl)/api/v1/timelines/home?limit=52&max_id=321>; rel=\"next\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        XCTAssertEqual(pagination.sinceId, "123")
        XCTAssertNil(pagination.minId)
        XCTAssertEqual(pagination.maxId, "321")
    }

    func testPaginationTolleratesSpacesAndNewLines() {
        let links: String = [
            "\n <https://m.iamkonstantin.eu/api/v1/notifications?limit=20&max_id=15223&offset=0&types[]=mention>; rel=\"next\"\n "
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        XCTAssertNil(pagination.sinceId)
        XCTAssertNil(pagination.minId)
        XCTAssertEqual(pagination.maxId, "15223")
    }
}
