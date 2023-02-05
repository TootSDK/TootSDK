/// A basic `CodingKey` implementation.
internal enum BasicCodingKey: CodingKey {
    case key(String)
    case index(Int)

    /// See `CodingKey`.
    var stringValue: String {
        switch self {
        case .index(let index): return index.description
        case .key(let key): return key
        }
    }

    /// See `CodingKey`.
    var intValue: Int? {
        switch self {
        case .index(let index): return index
        case .key(let key): return Int(key)
        }
    }

    /// See `CodingKey`.
    init?(stringValue: String) {
        self = .key(stringValue)
    }

    /// See `CodingKey`.
    init?(intValue: Int) {
        self = .index(intValue)
    }

    static let `super` = Self.key("super")
}
