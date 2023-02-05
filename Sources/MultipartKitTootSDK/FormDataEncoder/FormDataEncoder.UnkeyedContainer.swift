extension FormDataEncoder {
    struct UnkeyedContainer {
        let dataContainer = UnkeyedDataContainer()
        let encoder: FormDataEncoder.Encoder
    }
}

extension FormDataEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] {
        encoder.codingPath
    }

    var count: Int {
        dataContainer.value.count
    }

    func encodeNil() throws {
        // skip
    }

    func encode<T: Encodable>(_ value: T) throws {
        try nextEncoder().encode(value)
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        nextEncoder().container(keyedBy: keyType)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        nextEncoder().unkeyedContainer()
    }

    func superEncoder() -> Encoder {
        nextEncoder()
    }

    func nextEncoder() -> FormDataEncoder.Encoder {
        let encoder = self.encoder.nested(at: BasicCodingKey.index(count))
        dataContainer.value.append(encoder.storage)
        return encoder
    }
}
