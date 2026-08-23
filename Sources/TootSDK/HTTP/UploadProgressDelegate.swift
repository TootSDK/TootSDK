import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
internal final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let reportProgress: @Sendable (Double) -> Void
    private let lock = NSLock()
    private var lastProgress = 0.0
    private var transmissionFinished = false

    internal init(reportProgress: @escaping @Sendable (Double) -> Void) {
        self.reportProgress = reportProgress
    }

    internal func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard totalBytesExpectedToSend > 0 else {
            return
        }

        let progress = min(max(Double(totalBytesSent) / Double(totalBytesExpectedToSend), 0), 1)
        yield(progress)
    }

    internal func finishTransmission() {
        lock.withLock {
            guard !transmissionFinished else {
                return
            }

            if lastProgress < 1 {
                reportProgress(1)
                lastProgress = 1
            }
            transmissionFinished = true
        }
    }

    private func yield(_ progress: Double) {
        lock.withLock {
            guard !transmissionFinished, progress > lastProgress else {
                return
            }

            reportProgress(progress)
            lastProgress = progress
        }
    }
}
