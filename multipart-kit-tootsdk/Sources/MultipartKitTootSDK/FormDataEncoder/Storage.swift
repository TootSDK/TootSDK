import Collections

final class Storage {
    var dataContainer: DataContainer? = nil
    var data: MultipartFormData? {
        dataContainer?.data
    }
}

protocol DataContainer {
    var data: MultipartFormData { get }
}

struct SingleValueDataContainer: DataContainer {
    init(part: MultipartPart) {
        data = .single(part)
    }
    let data: MultipartFormData
}

final class KeyedDataContainer: DataContainer {
    var value: OrderedDictionary<String, Storage> = [:]
    var data: MultipartFormData {
        .keyed(value.compactMapValues(\.data))
    }
}

final class UnkeyedDataContainer: DataContainer {
    var value: [Storage] = []
    var data: MultipartFormData {
        .array(value.compactMap(\.data))
    }
}
