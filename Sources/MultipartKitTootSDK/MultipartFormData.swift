import Collections

enum MultipartFormData: Equatable {
    typealias Keyed = OrderedDictionary<String, MultipartFormData>

    case single(MultipartPart)
    case array([MultipartFormData])
    case keyed(Keyed)
    case nestingDepthExceeded

    init(parts: [MultipartPart], nestingDepth: Int) {
        self = parts.reduce(into: .empty) { result, part in
            result.insert(
                part,
                at: part.name.map(makePath) ?? [],
                remainingNestingDepth: nestingDepth
            )
        }
    }

    static let empty = MultipartFormData.keyed([:])

    var array: [MultipartFormData]? {
        guard case let .array(array) = self else { return nil }
        return array
    }

    var dictionary: Keyed? {
        guard case let .keyed(dict) = self else { return nil }
        return dict
    }

    var part: MultipartPart? {
        guard case let .single(part) = self else { return nil }
        return part
    }

    var hasExceededNestingDepth: Bool {
        guard case .nestingDepthExceeded = self else {
            return false
        }
        return true
    }
}

private func makePath(from string: String) -> ArraySlice<Substring> {
    ArraySlice(string.replacingOccurrences(of: "]", with: "").split(omittingEmptySubsequences: false) { $0 == "[" })
}

extension MultipartFormData {
    func namedParts() -> [MultipartPart] {
        Self.namedParts(from: self)
    }

    private static func namedParts(from data: MultipartFormData, path: String? = nil) -> [MultipartPart] {
        switch data {
        case .array(let array):
            return array.enumerated().flatMap { offset, element in
                namedParts(from: element, path: path.map { "\($0)[]" }) }
        case .single(var part):
            part.name = path
            return [part]
        case .keyed(let dictionary):
            return dictionary.flatMap { key, value in
                namedParts(from: value, path: path.map { "\($0)[\(key)]" } ?? key)
            }
        case .nestingDepthExceeded:
            return []
        }
    }
}

private extension MultipartFormData {
    mutating func insert(_ part: MultipartPart, at path: ArraySlice<Substring>, remainingNestingDepth: Int) {
        self = inserting(part, at: path, remainingNestingDepth: remainingNestingDepth)
    }

    func inserting(_ part: MultipartPart, at path: ArraySlice<Substring>, remainingNestingDepth: Int) -> MultipartFormData {
        guard let head = path.first else {
            return .single(part)
        }

        guard remainingNestingDepth > 1 else {
            return .nestingDepthExceeded
        }

        func insertPart(into data: inout MultipartFormData) {
            data.insert(part, at: path.dropFirst(), remainingNestingDepth: remainingNestingDepth - 1)
        }

        func insertingPart(at index: Int?) -> MultipartFormData {
            var array = self.array ?? []
            let count = array.count
            let index = index ?? count

            switch index {
            case count:
                array.append(.empty)
            case 0..<count:
                break
            default:
                // ignore indices outside the range of 0...count
                return self
            }

            insertPart(into: &array[index])
            return .array(array)
        }

        if head.isEmpty {
            return insertingPart(at: nil)
        } else if let index = Int(head) {
            return insertingPart(at: index)
        } else {
            var dictionary = self.dictionary ?? [:]
            insertPart(into: &dictionary[String(head), default: .empty])
            return .keyed(dictionary)
        }
    }
}
