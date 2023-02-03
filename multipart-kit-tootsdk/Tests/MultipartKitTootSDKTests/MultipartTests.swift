import XCTest
import MultipartKitTootSDK

class MultipartTests: XCTestCase {
    let named = """
    test123
    aijdisadi>SDASD<a|

    """

    let multinamed = """
    test123
    aijdisadi>dwekqie4u219034u129e0wque90qjsd90asffs


    SDASD<a|

    """

    func testBasics() throws {
        let data = """
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn\r
        Content-Disposition: form-data; name="test"\r
        \r
        eqw-dd-sa----123;1[234\r
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn\r
        Content-Disposition: form-data; name="named"; filename=""\r
        \r
        \(named)\r
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn\r
        Content-Disposition: form-data; name="multinamed[]"; filename=""\r
        \r
        \(multinamed)\r
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn--\r\n
        """

        let parts = try MultipartParserOutputReceiver
            .collectOutput(data, boundary: "----WebKitFormBoundaryPVOZifB9OqEwP2fn")
            .parts

        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(parts.firstPart(named: "test")?.body.string, "eqw-dd-sa----123;1[234")
        XCTAssertEqual(parts.firstPart(named: "named")?.body.string, named)
        XCTAssertEqual(parts.firstPart(named: "multinamed[]")?.body.string, multinamed)

        let serialized = try MultipartSerializer().serialize(parts: parts, boundary: "----WebKitFormBoundaryPVOZifB9OqEwP2fn")
        XCTAssertEqual(serialized, data)
    }
    
    func testNonAsciiHeader() throws {
        let filename = "Non-ASCII filé namé.txt"
        let data = """
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn\r
        Content-Disposition: form-data; name="test"; filename="\(filename)"\r
        \r
        eqw-dd-sa----123;1[234\r
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn--\r\n
        """

        let parts = try MultipartParserOutputReceiver
            .collectOutput(data, boundary: "----WebKitFormBoundaryPVOZifB9OqEwP2fn")
            .parts

        let contentDisposition = parts.firstPart(named: "test")!.headers
            .first(name: "Content-Disposition")!
        XCTAssert(contentDisposition.contains(filename))
    }

    func testMultifile() throws {
        let data = """
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn\r
        Content-Disposition: form-data; name="test"\r
        \r
        eqw-dd-sa----123;1[234\r
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn\r
        Content-Disposition: form-data; name="multinamed[]"; filename=""\r
        \r
        \(named)\r
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn\r
        Content-Disposition: form-data; name="multinamed[]"; filename=""\r
        \r
        \(multinamed)\r
        ------WebKitFormBoundaryPVOZifB9OqEwP2fn--\r\n
        """

        let parts = try MultipartParserOutputReceiver
            .collectOutput(data, boundary: "----WebKitFormBoundaryPVOZifB9OqEwP2fn")
            .parts

        let file = parts.firstPart(named: "multinamed[]")?.body
        XCTAssertEqual(file?.string, named)
        try XCTAssertEqual(MultipartSerializer().serialize(parts: parts, boundary: "----WebKitFormBoundaryPVOZifB9OqEwP2fn"), data)
    }

    func testFormDataDecoderW3Streaming() throws {
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

        let expected = [
            MultipartPart(
                headers: ["Content-Disposition": "form-data; name=\"sometext\""],
                body: "some text sent via post..."
            ),
            MultipartPart(
                headers: ["Content-Disposition": "form-data; name=\"files\"", "Content-Type": "multipart/mixed; boundary=abcde"],
                body: "--abcde\r\nContent-Disposition: file; file=\"picture.jpg\"\r\n\r\ncontent of jpg...\r\n--abcde\r\nContent-Disposition: file; file=\"test.py\"\r\n\r\ncontent of test.py file ....\r\n--abcde--"
            )
        ]

        for i in 1..<data.count {
            let parser = MultipartParser(boundary: "12345")
            let output = MultipartParserOutputReceiver()
            output.setUp(with: parser)

            for chunk in data.chunked(by: i) {
                try parser.execute(.init(chunk))
            }

            XCTAssertEqual(output.parts, expected)
        }
    }

    func testDocBlocks() throws {
        do {
            /// Content-Type: multipart/form-data; boundary=123
            let data = """
            --123\r
            \r
            foo\r
            --123--\r\n
            """
            let parts = try MultipartParserOutputReceiver
                .collectOutput(data, boundary: "123")
                .parts

            XCTAssertEqual(parts.count, 1)
        }
        do {
            let part = MultipartPart(body: "foo")
            let data = try MultipartSerializer().serialize(parts: [part], boundary: "123")
            XCTAssertEqual(data, "--123\r\n\r\nfoo\r\n--123--\r\n")
        }
    }

    func testAllowedHeaderFieldNameCharacters() {
        let disallowedASCIICodes: [Int] = (0...127).compactMap {
            let parser = MultipartParser(boundary: "-")
            let body: String = """
            ---\r
            a\(Unicode.Scalar($0)!): b\r
            \r
            c\r
            ---\r\n
            """
            do {
                try parser.execute(body)
                return nil
            } catch {
                return $0
            }
        }
        let expectedDisallowedASCIICodes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 34, 40, 41, 44, 47, 59, 60, 61, 62, 63, 64, 91, 92, 93, 123, 125, 127]
        XCTAssertEqual(disallowedASCIICodes, expectedDisallowedASCIICodes)
    }

    func testPreamble() throws {
        let dataWithPreamble = """
        preamble\r
        ---\r
        \r
        body
        """

        let output = try MultipartParserOutputReceiver.collectOutput( dataWithPreamble, boundary: "-")
        XCTAssertEqual(output.body.string, "body")

        let dataWithoutPreamble = """
        ---\r
        \r
        body
        """

        let output2 = try MultipartParserOutputReceiver.collectOutput(dataWithoutPreamble, boundary: "-")
        XCTAssertEqual(output2.body.string, "body")
    }

    func testBodyClose() throws {
        // this tests handling a "false start" for the closing boundary of a body
        let data = """
        ---\r
        \r
        body\r
        -\r
        ---\r
        """

        let output = try MultipartParserOutputReceiver.collectOutput(data, boundary: "-")
        XCTAssertEqual(output.parts.count, 1)
    }

    func testPerformance() throws {
        let testSize: Int
        #if DEBUG
            #warning("Performance test results in debug configuration are not a good indicator for performance in release configuration.")
            testSize = 100_000
        #else
            testSize = 100_000_000
        #endif

        var buf = ByteBuffer(string: "---\r\n\r\n")
        buf.writeRepeatingByte(.init(ascii: "a"), count: testSize)
        buf.writeString("\r\n-----\r\n")

        measure {
            do {
                let receiver = try MultipartParserOutputReceiver.collectOutput(buf, boundary: "-")
                XCTAssertEqual(receiver.parts[0].body.readableBytes, testSize)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// https://stackoverflow.com/a/54524110/1041105
private extension Collection {
    func chunked(by maxLength: Int) -> [SubSequence] {
        precondition(maxLength > 0, "groups must be greater than zero")
        var start = startIndex
        return stride(from: 0, to: count, by: maxLength).map { _ in
            let end = index(start, offsetBy: maxLength, limitedBy: endIndex) ?? endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}

extension ByteBuffer {
    var string: String {
        String(buffer: self)
    }
}

private class MultipartParserOutputReceiver {
    var parts: [MultipartPart] = []
    var headers: HTTPHeaders = [:]
    var body: ByteBuffer = ByteBuffer()

    static func collectOutput(_ data: String, boundary: String) throws -> MultipartParserOutputReceiver {
        try collectOutput(ByteBuffer(string: data), boundary: boundary)
    }

    static func collectOutput(_ data: ByteBuffer, boundary: String) throws -> MultipartParserOutputReceiver {
        let output = MultipartParserOutputReceiver()
        let parser = MultipartParser(boundary: boundary)
        output.setUp(with: parser)
        try parser.execute(data)
        return output
    }

    func setUp(with parser: MultipartParser) {
        parser.onHeader = { (field, value) in
            self.headers.replaceOrAdd(name: field, value: value)
        }
        parser.onBody = { new in
            self.body.writeBuffer(&new)
        }
        parser.onPartComplete = {
            let part = MultipartPart(headers: self.headers, body: self.body)
            self.headers = [:]
            self.body = ByteBuffer()
            self.parts.append(part)
        }
    }
}
