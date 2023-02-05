extension FormDataEncoder.Encoder: SingleValueEncodingContainer {
    func encodeNil() throws {
        // skip
    }

    func encode<T: Encodable>(_ value: T) throws {
        if
            let convertible = value as? MultipartPartConvertible,
            let part = convertible.multipart
        {
            storage.dataContainer = SingleValueDataContainer(part: part)
        } else {
            try value.encode(to: self)
        }
    }
}
