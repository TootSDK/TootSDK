import struct NIO.ByteBufferAllocator

/// Encodes `Encodable` items to `multipart/form-data` encoded `Data`.
///
/// See [RFC#2388](https://tools.ietf.org/html/rfc2388) for more information about `multipart/form-data` encoding.
///
/// Seealso `MultipartParser` for more information about the `multipart` encoding.
public struct FormDataEncoder {

    /// Any contextual information set by the user for encoding.
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Creates a new `FormDataEncoder`.
    public init() {}

    /// Encodes an `Encodable` item to `String` using the supplied boundary.
    ///
    ///     let a = Foo(string: "a", int: 42, double: 3.14, array: [1, 2, 3])
    ///     let data = try FormDataEncoder().encode(a, boundary: "123")
    ///
    /// - parameters:
    ///     - encodable: Generic `Encodable` item.
    ///     - boundary: Multipart boundary to use for encoding. This must not appear anywhere in the encoded data.
    /// - throws: Any errors encoding the model with `Codable` or serializing the data.
    /// - returns: `multipart/form-data`-encoded `String`.
    public func encode<E: Encodable>(_ encodable: E, boundary: String) throws -> String {
        try MultipartSerializer().serialize(parts: parts(from: encodable), boundary: boundary)
    }

    /// Encodes an `Encodable` item into a `ByteBuffer` using the supplied boundary.
    ///
    ///     let a = Foo(string: "a", int: 42, double: 3.14, array: [1, 2, 3])
    ///     var buffer = ByteBuffer()
    ///     let data = try FormDataEncoder().encode(a, boundary: "123", into: &buffer)
    ///
    /// - parameters:
    ///     - encodable: Generic `Encodable` item.
    ///     - boundary: Multipart boundary to use for encoding. This must not appear anywhere in the encoded data.
    ///     - buffer: Buffer to write to.
    /// - throws: Any errors encoding the model with `Codable` or serializing the data.
    public func encode<E: Encodable>(_ encodable: E, boundary: String, into buffer: inout ByteBuffer) throws {
        try MultipartSerializer().serialize(parts: parts(from: encodable), boundary: boundary, into: &buffer)
    }

    private func parts<E: Encodable>(from encodable: E) throws -> [MultipartPart] {
        let encoder = Encoder(codingPath: [], userInfo: userInfo)
        try encodable.encode(to: encoder)
        return encoder.storage.data?.namedParts() ?? []
    }
}
