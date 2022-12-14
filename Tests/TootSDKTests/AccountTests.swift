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
    
    func testRichDisplayName() throws {
        // arrange
        let decoder = TootDecoder()
        let account = try decoder.decode(Account.self, from: localContent("account"))

        // assert
        XCTAssertEqual(account.tootRichDisplayName, "ikea shark fan account <img src=\"https://files.mastodon.social/custom_emojis/images/000/028/691/original/6de008d6281f4f59.png\" alt=\"ms_rainbow_flag\" title=\"ms_rainbow_flag\">")
    }
}
