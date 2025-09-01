//
//  XCTestCase+LocalContent.swift
//
//
//  Created by konstantin on 30/10/2022.
//

import Foundation
import XCTest

@testable import TootSDK

// swift-format-ignore: AlwaysUseLowerCamelCase
func URLForResource(fileName: String, withExtension: String) -> URL {
    return URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Resources")
        .appendingPathComponent(fileName)
        .appendingPathExtension(withExtension)
}

func localContent(_ fileName: String, _ fileExtension: String = "json") -> Data {
    let url = URLForResource(fileName: fileName, withExtension: fileExtension)
    return try! Data.init(contentsOf: url)
}

func localObject<T>(_ type: T.Type, _ filename: String) throws -> T where T: Decodable {
    let json = localContent(filename)
    let decoder = TootDecoder()
    return try decoder.decode(type, from: json)
}
