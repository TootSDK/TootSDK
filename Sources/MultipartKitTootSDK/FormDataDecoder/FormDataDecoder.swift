/// Decodes `Decodable` types from `multipart/form-data` encoded `Data`.
///
/// See [RFC#2388](https://tools.ietf.org/html/rfc2388) for more information about `multipart/form-data` encoding.
///
/// Seealso `MultipartParser` for more information about the `multipart` encoding.
public struct FormDataDecoder {

    /// Maximum nesting depth to allow when decoding the input.
    /// - 1 corresponds to a single value
    /// - 2 corresponds to an an object with non-nested properties or an 1 dimensional array
    /// - 3... corresponds to nested objects or multi-dimensional arrays or combinations thereof
    let nestingDepth: Int

    /// Any contextual information set by the user for decoding.
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Creates a new `FormDataDecoder`.
    /// - Parameter nestingDepth: maximum allowed nesting depth of the decoded structure. Defaults to 8.
    public init(nestingDepth: Int = 8) {
        self.nestingDepth = nestingDepth
    }

    /// Decodes a `Decodable` item from `String` using the supplied boundary.
    ///
    ///     let foo = try FormDataDecoder().decode(Foo.self, from: "...", boundary: "123")
    ///
    /// - Parameters:
    ///   - decodable: Generic `Decodable` type.
    ///   - data: String to decode.
    ///   - boundary: Multipart boundary to used in the decoding.
    /// - Throws: Any errors decoding the model with `Codable` or parsing the data.
    /// - Returns: An instance of the decoded type `D`.
    public func decode<D: Decodable>(_ decodable: D.Type, from data: String, boundary: String) throws -> D {
        try decode(D.self, from: ByteBuffer(string: data), boundary: boundary)
    }

    /// Decodes a `Decodable` item from `Data` using the supplied boundary.
    ///
    ///     let foo = try FormDataDecoder().decode(Foo.self, from: data, boundary: "123")
    ///
    /// - Parameters:
    ///   - decodable: Generic `Decodable` type.
    ///   - data: Data to decode.
    ///   - boundary: Multipart boundary to used in the decoding.
    /// - Throws: Any errors decoding the model with `Codable` or parsing the data.
    /// - Returns: An instance of the decoded type `D`.
    public func decode<D: Decodable>(_ decodable: D.Type, from data: [UInt8], boundary: String) throws -> D {
        try decode(D.self, from: ByteBuffer(bytes: data), boundary: boundary)
    }

    /// Decodes a `Decodable` item from `Data` using the supplied boundary.
    ///
    ///     let foo = try FormDataDecoder().decode(Foo.self, from: data, boundary: "123")
    ///
    /// - Parameters:
    ///   - decodable: Generic `Decodable` type.
    ///   - data: Data to decode.
    ///   - boundary: Multipart boundary to used in the decoding.
    /// - Throws: Any errors decoding the model with `Codable` or parsing the data.
    /// - Returns: An instance of the decoded type `D`.
    public func decode<D: Decodable>(_ decodable: D.Type, from buffer: ByteBuffer, boundary: String) throws -> D {
        let parser = MultipartParser(boundary: boundary)

        var parts: [MultipartPart] = []
        var headers: HTTPHeaders = .init()
        var body: ByteBuffer = ByteBuffer()

        parser.onHeader = { (field, value) in
            headers.replaceOrAdd(name: field, value: value)
        }
        parser.onBody = { new in
            body.writeBuffer(&new)
        }
        parser.onPartComplete = {
            let part = MultipartPart(headers: headers, body: body)
            headers = [:]
            body = ByteBuffer()
            parts.append(part)
        }

        try parser.execute(buffer)
        let data = MultipartFormData(parts: parts, nestingDepth: nestingDepth)
        let decoder = Decoder(codingPath: [], data: data, userInfo: userInfo)
        return try decoder.decode()
    }
}
