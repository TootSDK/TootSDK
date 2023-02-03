extension FormDataDecoder {
    struct UnkeyedContainer {
        var currentIndex: Int = 0
        let data: [MultipartFormData]
        let decoder: FormDataDecoder.Decoder
    }
}

extension FormDataDecoder.UnkeyedContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] {
        decoder.codingPath
    }
    var count: Int? { data.count }
    var index: CodingKey { BasicCodingKey.index(currentIndex) }
    var isAtEnd: Bool { currentIndex >= data.count }

    mutating func decodeNil() throws -> Bool {
        false
    }

    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try decoderAtIndex().decode(T.self)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        try decoderAtIndex().container(keyedBy: keyType)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try decoderAtIndex().unkeyedContainer()
    }

    mutating func superDecoder() throws -> Decoder {
        try decoderAtIndex()
    }

    mutating func decoderAtIndex() throws -> FormDataDecoder.Decoder {
        defer { currentIndex += 1 }
        return try decoder.nested(at: index, with: getValue())
    }

    mutating func getValue() throws -> MultipartFormData {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(
                FormDataDecoder.Decoder.self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unkeyed container is at end.",
                    underlyingError: nil
                )
            )
        }
        return data[currentIndex]
    }
}
