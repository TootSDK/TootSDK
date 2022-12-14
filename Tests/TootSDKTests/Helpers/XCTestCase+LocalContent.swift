//
//  XCTestCase+LocalContent.swift
//  
//
//  Created by konstantin on 30/10/2022.
//

import Foundation
import XCTest

extension XCTestCase {
    func URLForResource(fileName: String, withExtension: String) -> URL {
        return Bundle.module.url(forResource: fileName, withExtension: withExtension)!
    }
    
    func localContent(_ fileName: String, _ fileExtension: String = "json") -> Data {
        let url = URLForResource(fileName: fileName, withExtension: fileExtension)
        return try! Data.init(contentsOf: url)
    }
}
