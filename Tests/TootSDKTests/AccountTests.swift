import XCTest
@testable import TootSDK

final class AccountTests: XCTestCase {
    func testDecoding() throws {
        // arrange
        let json = localContent("account")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(Account.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "23634")
    }
    
    func testDecodingIndirectOptional() throws {
        // arrange
        let json = localContent("account_moved")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(Account.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertNotNil(result.moved)
        XCTAssertEqual(result.moved?.id, "23634")
    }
    
    func testEncoding() throws {
        // arrange
        let json = localContent("account")
        let decoder = TootDecoder()
        let encoder = TootEncoder()
        let model = try decoder.decode(Account.self, from: json)
        
        // act
        let encodedData = try encoder.encode(model)
        let encodedModel = try decoder.decode(Account.self, from: encodedData)
        
        // assert
        XCTAssertNotNil(encodedModel)
        XCTAssertEqual(encodedModel, model)
//        XCTAssertEqual(encodedData.hashValue, model.hashValue)
    }
    
    func testDecodingPixelfed() throws {
        // arrange
        let json = localContent("account_pixelfed")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(Account.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "569707951076919035")
    }
}
