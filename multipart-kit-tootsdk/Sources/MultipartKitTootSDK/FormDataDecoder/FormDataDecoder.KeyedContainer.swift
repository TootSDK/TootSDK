extension FormDataDecoder {
    struct KeyedContainer<K: CodingKey> {
        let data: MultipartFormData.Keyed
        let decoder: FormDataDecoder.Decoder
    }
}

extension FormDataDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
    var allKeys: [K] {
        data.keys.compactMap(K.init(stringValue:))
    }

    var codingPath: [CodingKey] {
        decoder.codingPath
    }

    func contains(_ key: K) -> Bool {
        data.keys.contains(key.stringValue)
    }

    func getValue(forKey key: CodingKey) throws -> MultipartFormData {
        guard let value = data[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key, .init(
                    codingPath: codingPath,
                    debugDescription: "No value associated with key \"\(key.stringValue)\"."
                )
            )
        }
        return value
    }

    func decodeNil(forKey key: K) throws -> Bool {
        false
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
        try decoderForKey(key).decode()
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> {
        try decoderForKey(key).container(keyedBy: keyType)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        try decoderForKey(key).unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        try decoderForKey(BasicCodingKey.super)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        try decoderForKey(key)
    }

    func decoderForKey(_ key: CodingKey) throws -> FormDataDecoder.Decoder {
        decoder.nested(at: key, with: try getValue(forKey: key))
    }
}
