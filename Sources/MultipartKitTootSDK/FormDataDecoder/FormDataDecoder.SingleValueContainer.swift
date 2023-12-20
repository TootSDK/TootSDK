extension FormDataDecoder.Decoder: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        false
    }

    func decode<T: Decodable>(_: T.Type = T.self) throws -> T {
        // swift-format-ignore: AlwaysUseLowerCamelCase
        guard
            let part = data.part,
            let Convertible = T.self as? MultipartPartConvertible.Type
        else {
            return try T(from: self)
        }

        guard !data.hasExceededNestingDepth else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Nesting depth exceeded.", underlyingError: nil))
        }

        guard
            let decoded = Convertible.init(multipart: part) as? T
        else {
            let path = codingPath.map(\.stringValue).joined(separator: ".")
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: #"Could not convert value at "\#(path)" to type \#(T.self) from multipart part."#
                )
            )
        }
        return decoded
    }
}
