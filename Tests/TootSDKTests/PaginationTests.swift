// Created by konstantin on 05/11/2022.
// Copyright (c) 2022. All rights reserved.

import Testing

@testable import TootSDK

@Suite struct PaginationTests {
    let serverUrl: String = "https://m.iamkonstantin.eu"

    @Test func paginationWithInvalidNextAndPrevious() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?max_id=420>; rel=\"\"",
            "this is not a valid URL; rel=\"next\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        #expect(pagination.prev == nil)
        #expect(pagination.next == nil)
    }

    @Test func paginationWithValidNext() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?limit=42&max_id=420>; rel=\"next\"",
            "this is not a valid URL; rel=\"prev\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        #expect(pagination.prev == nil)

        #expect(pagination.next?.minId == nil)
        #expect(pagination.next?.sinceId == nil)
        #expect(pagination.next?.maxId == "420")
    }

    @Test func paginationWithValidPrevious() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?limit=42&since_id=420>; rel=\"prev\"",
            "this is not a valid URL; rel=\"next\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        #expect(pagination.prev?.minId == nil)
        #expect(pagination.prev?.sinceId == "420")
        #expect(pagination.prev?.maxId == nil)

        #expect(pagination.next == nil)
    }

    @Test func paginationWithValidNextAndPrevious() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?limit=42&since_id=123>; rel=\"prev\"",
            "<\(serverUrl)/api/v1/timelines/home?limit=52&max_id=321>; rel=\"next\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        #expect(pagination.prev?.minId == nil)
        #expect(pagination.prev?.sinceId == "123")
        #expect(pagination.prev?.maxId == nil)

        #expect(pagination.next?.minId == nil)
        #expect(pagination.next?.sinceId == nil)
        #expect(pagination.next?.maxId == "321")
    }

    @Test func paginationTolleratesSpacesAndNewLines() {
        let links: String = [
            "\n <https://m.iamkonstantin.eu/api/v1/notifications?limit=20&max_id=15223&offset=0&types[]=mention>; rel=\"next\"\n "
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        #expect(pagination.prev == nil)

        #expect(pagination.next?.minId == nil)
        #expect(pagination.next?.sinceId == nil)
        #expect(pagination.next?.maxId == "15223")
    }

    @Test func paginationWithSameParameterNamesInNextAndPrevious() {
        let links = [
            "<\(serverUrl)/api/v1/timelines/home?limit=42&since_id=123&min_id=456&max_id=789>; rel=\"prev\"",
            "<\(serverUrl)/api/v1/timelines/home?limit=52&max_id=321&min_id=654&since_id=987>; rel=\"next\"",
        ].joined(separator: ",")

        let pagination = Pagination(links: links)

        #expect(pagination.prev?.minId == "456")
        #expect(pagination.prev?.sinceId == "123")
        #expect(pagination.prev?.maxId == "789")

        #expect(pagination.next?.minId == "654")
        #expect(pagination.next?.sinceId == "987")
        #expect(pagination.next?.maxId == "321")
    }
}
