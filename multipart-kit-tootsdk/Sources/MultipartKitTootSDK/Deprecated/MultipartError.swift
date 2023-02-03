@available(*, deprecated)
public enum MultipartError: Error, CustomStringConvertible {
    case invalidFormat
    case convertibleType(Any.Type)
    case convertiblePart(Any.Type, MultipartPart)
    case nesting
    case missingPart(String)
    case missingFilename
    
    public var description: String { "" }
}
