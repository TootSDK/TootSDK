import XCTest
import MultipartKitTootSDK

class FormDataTests: XCTestCase {
    func testFormDataEncoder() throws {
        struct Foo: Encodable {
            var string: String
            var int: Int
            var double: Double
            var array: [Int]
            var bool: Bool
        }
        let a = Foo(string: "a", int: 42, double: 3.14, array: [1, 2, 3], bool: true)
        let data = try FormDataEncoder().encode(a, boundary: "hello")
        XCTAssertEqual(data, """
        --hello\r
        Content-Disposition: form-data; name="string"\r
        \r
        a\r
        --hello\r
        Content-Disposition: form-data; name="int"\r
        \r
        42\r
        --hello\r
        Content-Disposition: form-data; name="double"\r
        \r
        3.14\r
        --hello\r
        Content-Disposition: form-data; name="array[0]"\r
        \r
        1\r
        --hello\r
        Content-Disposition: form-data; name="array[1]"\r
        \r
        2\r
        --hello\r
        Content-Disposition: form-data; name="array[2]"\r
        \r
        3\r
        --hello\r
        Content-Disposition: form-data; name="bool"\r
        \r
        true\r
        --hello--\r\n
        """)
    }

    func testFormDataDecoderW3() throws {
        /// Content-Type: multipart/form-data; boundary=12345
        let data = """
        --12345\r
        Content-Disposition: form-data; name="sometext"\r
        \r
        some text sent via post...\r
        --12345\r
        Content-Disposition: form-data; name="files"\r
        Content-Type: multipart/mixed; boundary=abcde\r
        \r
        --abcde\r
        Content-Disposition: file; file="picture.jpg"\r
        \r
        content of jpg...\r
        --abcde\r
        Content-Disposition: file; file="test.py"\r
        \r
        content of test.py file ....\r
        --abcde--\r
        --12345--\r\n
        """

        struct Foo: Decodable {
            let sometext: String
            let files: String
        }

        let foo = try FormDataDecoder().decode(Foo.self, from: data, boundary: "12345")
        XCTAssertEqual(foo.sometext, "some text sent via post...")
        XCTAssert(foo.files.contains("picture.jpg"))
    }

    func testDecodeOptional() throws {
        struct Bar: Decodable {
            struct Foo: Decodable {
                let int: Int?
            }
            let foo: Foo?
        }
        let data = """
        ---\r
        Content-Disposition: form-data; name="foo[int]"\r
        \r
        1\r
        -----\r\n
        """

        let decoder = FormDataDecoder()
        let bar = try decoder.decode(Bar?.self, from: data, boundary: "-")
        XCTAssertEqual(bar?.foo?.int, 1)
    }

    func testFormDataDecoderMultiple() throws {
        /// Content-Type: multipart/form-data; boundary=12345
        let data = """
        --hello\r
        Content-Disposition: form-data; name="string"\r
        \r
        string\r
        --hello\r
        Content-Disposition: form-data; name="int"\r
        \r
        42\r
        --hello\r
        Content-Disposition: form-data; name="double"\r
        \r
        3.14\r
        --hello\r
        Content-Disposition: form-data; name="array[]"\r
        \r
        1\r
        --hello\r
        Content-Disposition: form-data; name="array[]"\r
        \r
        2\r
        --hello\r
        Content-Disposition: form-data; name="array[]"\r
        \r
        3\r
        --hello\r
        Content-Disposition: form-data; name="bool"\r
        \r
        true\r
        --hello--\r\n
        """

        struct Foo: Decodable {
            var string: String
            var int: Int
            var double: Double
            var array: [Int]
            var bool: Bool
        }

        let foo = try FormDataDecoder().decode(Foo.self, from: data, boundary: "hello")
        XCTAssertEqual(foo.string, "string")
        XCTAssertEqual(foo.int, 42)
        XCTAssertEqual(foo.double, 3.14)
        XCTAssertEqual(foo.array, [1, 2, 3])
        XCTAssertEqual(foo.bool, true)
    }

    func testFormDataDecoderMultipleWithMissingData() {
        /// Content-Type: multipart/form-data; boundary=hello
        let data = """
        --hello\r
        Content-Disposition: form-data; name="link"\r
        \r
        https://google.com\r
        --hello--\r\n
        """

        struct Foo: Decodable {
            var link: URL
        }

        XCTAssertThrowsError(try FormDataDecoder().decode(Foo.self, from: data, boundary: "hello")) { error in
            guard case let DecodingError.typeMismatch(_, context) = error else {
                XCTFail("Was expecting an error of type DecodingError.typeMismatch")
                return
            }
            XCTAssertEqual(context.codingPath.map(\.stringValue), ["link"])
        }
    }

    func testNestedEncode() throws {
        struct Formdata: Encodable, Equatable {
            struct NestedFormdata: Encodable, Equatable {
                struct AnotherNestedFormdata: Encodable, Equatable {
                    let int: Int
                    let string: String
                    let strings: [String]
                }
                let int: String
                let string: Int
                let strings: [String]
                let anotherNestedFormdata: AnotherNestedFormdata
                let anotherNestedFormdataList: [AnotherNestedFormdata]
            }
            let nestedFormdata: [NestedFormdata]
        }

        let encoder = FormDataEncoder()
        let data = try encoder.encode(Formdata(nestedFormdata: [
            .init(
                int: "1",
                string: 1,
                strings: ["2", "3"],
                anotherNestedFormdata: .init(int: 4, string: "5", strings: ["6", "7"]),
                anotherNestedFormdataList: [
                    .init(int: 10, string: "11", strings: ["12", "13"]),
                    .init(int: 20, string: "21", strings: ["22", "33"])
                ])
        ]), boundary: "-")
        let expected = """
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][int]"\r
        \r
        1\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][string]"\r
        \r
        1\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][strings][0]"\r
        \r
        2\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][strings][1]"\r
        \r
        3\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][int]"\r
        \r
        4\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][string]"\r
        \r
        5\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][strings][0]"\r
        \r
        6\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][strings][1]"\r
        \r
        7\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][int]"\r
        \r
        10\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][string]"\r
        \r
        11\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][strings][0]"\r
        \r
        12\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][strings][1]"\r
        \r
        13\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][int]"\r
        \r
        20\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][string]"\r
        \r
        21\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][strings][0]"\r
        \r
        22\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][strings][1]"\r
        \r
        33\r
        -----\r\n
        """

        XCTAssertEqual(data, expected)
    }

    func testNestedDecode() throws {
        struct Formdata: Decodable, Equatable {
            struct NestedFormdata: Decodable, Equatable {
                struct AnotherNestedFormdata: Decodable, Equatable {
                    let int: Int
                    let string: String
                    let strings: [String]
                }
                let int: String
                let string: Int
                let strings: [String]
                let anotherNestedFormdata: AnotherNestedFormdata
                let anotherNestedFormdataList: [AnotherNestedFormdata]
            }
            let nestedFormdata: [NestedFormdata]
        }

        let data = """
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][int]"\r
        \r
        1\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][string]"\r
        \r
        1\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][strings][0]"\r
        \r
        2\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][strings][1]"\r
        \r
        3\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][int]"\r
        \r
        4\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][string]"\r
        \r
        5\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][strings][0]"\r
        \r
        6\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdata][strings][1]"\r
        \r
        7\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][int]"\r
        \r
        10\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][string]"\r
        \r
        11\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][strings][0]"\r
        \r
        12\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][0][strings][1]"\r
        \r
        13\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][int]"\r
        \r
        20\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][string]"\r
        \r
        21\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][strings][0]"\r
        \r
        22\r
        ---\r
        Content-Disposition: form-data; name="nestedFormdata[0][anotherNestedFormdataList][1][strings][1]"\r
        \r
        33\r
        -----\r\n
        """

        let decoder = FormDataDecoder()
        let formdata = try decoder.decode(Formdata.self, from: data, boundary: "-")

        XCTAssertEqual(formdata, Formdata(nestedFormdata: [
            .init(
                int: "1",
                string: 1,
                strings: ["2", "3"],
                anotherNestedFormdata: .init(int: 4, string: "5", strings: ["6", "7"]),
                anotherNestedFormdataList: [
                    .init(int: 10, string: "11", strings: ["12", "13"]),
                    .init(int: 20, string: "21", strings: ["22", "33"])
                ])
        ]))
    }

    func testDecodingSingleValue() throws {
        let data = """
        ---\r
        \r
        1\r
        -----\r\n
        """

        let decoder = FormDataDecoder()
        let foo = try decoder.decode(Int.self, from: data, boundary: "-")
        XCTAssertEqual(foo, 1)
    }

    func testMultiPartConvertibleTakesPrecedenceOverDecodable() throws {
        struct Foo: Decodable, MultipartPartConvertible {
            var multipart: MultipartPart? { nil }

            let success: Bool

            init(from _: Decoder) throws {
                success = false
            }
            init?(multipart: MultipartPart) {
                success = true
            }
        }

        let singleValue = """
        ---\r
        \r
        \r
        -----\r\n
        """
        let decoder = FormDataDecoder()
        let singleFoo = try decoder.decode(Foo.self, from: singleValue, boundary: "-")
        XCTAssertTrue(singleFoo.success)

        let array = """
        ---\r
        Content-Disposition: form-data; name=""\r
        \r
        \r
        -----\r\n
        """

        let fooArray = try decoder.decode([Foo].self, from: array, boundary: "-")
        XCTAssertFalse(fooArray.isEmpty)
        XCTAssertTrue(fooArray.allSatisfy(\.success))

        let keyed = """
        ---\r
        Content-Disposition: form-data; name="a"\r
        \r
        \r
        -----\r\n
        """

        let keyedFoos = try decoder.decode([String: Foo].self, from: keyed, boundary: "-")
        XCTAssertFalse(keyedFoos.isEmpty)
        XCTAssertTrue(keyedFoos.values.allSatisfy(\.success))
    }

    func testNestingDepth() throws {
        let nested = """
        ---\r
        Content-Disposition: form-data; name=a[]\r
        \r
        1\r
        -----\r\n
        """

        XCTAssertNoThrow(try FormDataDecoder(nestingDepth: 3).decode([String: [Int]].self, from: nested, boundary: "-"))
        XCTAssertThrowsError(try FormDataDecoder(nestingDepth: 2).decode([String: [Int]].self, from: nested, boundary: "-"))
    }

    func testFailingToInitializeMultipartConvertableDoesNotCrash() throws {
        struct Foo: MultipartPartConvertible, Decodable {
            init?(multipart: MultipartPart) { nil }
            var multipart: MultipartPart? { nil }
        }

        let input = """
        ---\r
        \r
        \r
        null\r
        -----\r\n
        """
        XCTAssertThrowsError(try FormDataDecoder().decode(Foo.self, from: input, boundary: "-"))
    }

    func testEncodingAndDecodingUUID() throws {
        let uuid = try XCTUnwrap(UUID(uuidString: "c0bdd551-0684-4f34-a72e-ed553b4c9732"))
        let multipart = """
        ---\r
        Content-Disposition: form-data\r
        \r
        \(uuid.uuidString)\r
        -----\r\n
        """

        XCTAssertEqual(try FormDataEncoder().encode(uuid, boundary: "-"), multipart)
        XCTAssertEqual(try FormDataDecoder().decode(UUID.self, from: multipart, boundary: "-"), uuid)
    }

    // https://github.com/vapor/multipart-kit/issues/65
    func testEncodingAndDecodingNonMultipartPartConvertibleCodableTypes() throws {
        enum License: String, Codable, CaseIterable, Equatable {
            case dme1
        }
        let license = License.dme1
        let multipart = """
        ---\r
        Content-Disposition: form-data\r
        \r
        \(license.rawValue)\r
        -----\r\n
        """
        XCTAssertEqual(try FormDataEncoder().encode(license, boundary: "-"), multipart)
        XCTAssertEqual(try FormDataDecoder().decode(License.self, from: multipart, boundary: "-"), license)
    }
}
