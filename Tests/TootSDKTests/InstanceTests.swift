import XCTest
@testable import TootSDK

final class InstanceTests: XCTestCase {
    func testFriendicaNoContact() throws {
        // arrange
        let json = localContent("instance_friendica_nocontact")
        let decoder = TootDecoder()
        
        // act
        let result = try decoder.decode(Instance.self, from: json)
        
        // assert
        XCTAssertNotNil(result)
        XCTAssertNil(result.contactAccount)
    }
}
