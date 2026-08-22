/// An event emitted while uploading data.
public enum UploadEvent<Output: Sendable>: Sendable {
    /// Upload progress from `0` to `1`.
    case progress(Double)
    /// The value returned when the upload completes.
    case completed(Output)
}
