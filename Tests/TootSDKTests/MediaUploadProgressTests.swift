import Foundation
import Testing

@testable import TootSDK

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

@Suite(.serialized) struct MediaUploadProgressTests {
    @Test func progressIsMonotonicAndClamped() async throws {
        let (stream, continuation) = AsyncStream<Double>.makeStream()
        let delegate = UploadProgressDelegate { progress in
            continuation.yield(progress)
        }
        let task = URLSession.shared.dataTask(with: URL(string: "https://example.com")!)

        delegate.urlSession(
            URLSession.shared,
            task: task,
            didSendBodyData: 10,
            totalBytesSent: 10,
            totalBytesExpectedToSend: NSURLSessionTransferSizeUnknown
        )
        delegate.urlSession(
            URLSession.shared,
            task: task,
            didSendBodyData: 25,
            totalBytesSent: 25,
            totalBytesExpectedToSend: 100
        )
        delegate.urlSession(
            URLSession.shared,
            task: task,
            didSendBodyData: 5,
            totalBytesSent: 20,
            totalBytesExpectedToSend: 100
        )
        delegate.urlSession(
            URLSession.shared,
            task: task,
            didSendBodyData: 130,
            totalBytesSent: 150,
            totalBytesExpectedToSend: 100
        )
        delegate.finishTransmission()
        continuation.finish()

        var progress = [Double]()
        for await value in stream {
            progress.append(value)
        }
        #expect(progress == [0.25, 1])
    }

    @Test func uploadWithProgressReportsProgressAndReturnsAttachment() async throws {
        let client = makeClient(protocolClass: SuccessfulUploadURLProtocol.self)
        let params = UploadMediaAttachmentParams(file: Data("media".utf8), description: "Description")
        let reportedProgress = ProgressStorage()

        let completed = try await client.uploadMedia(params, mimeType: "image/jpeg") { progress in
            reportedProgress.append(progress)
        }
        let progress = reportedProgress.values
        #expect(progress.first == 0)
        #expect(progress.last == 1)
        #expect(progress == progress.sorted())

        let progressRequest = try #require(SuccessfulUploadURLProtocol.lastRequest)
        #expect(progressRequest.httpBody == nil)
        #expect(progressRequest.httpMethod == "POST")
        #expect(progressRequest.url?.path == "/api/v2/media")
        #expect(progressRequest.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data") == true)

        #expect(completed.id == "media-id")
        guard case .uploaded = completed.state else {
            Issue.record("Expected an uploaded attachment")
            return
        }
    }

    @Test func uploadUsesMultipartRequest() async throws {
        let client = makeClient(protocolClass: SuccessfulUploadURLProtocol.self)
        let params = UploadMediaAttachmentParams(file: Data("media".utf8), description: "Description")

        let result = try await client.uploadMedia(params, mimeType: "image/jpeg")
        #expect(result.id == "media-id")
        #expect(SuccessfulUploadURLProtocol.lastRequest?.httpMethod == "POST")
        #expect(SuccessfulUploadURLProtocol.lastRequest?.url?.path == "/api/v2/media")
        #expect(SuccessfulUploadURLProtocol.lastRequest?.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data") == true)
    }

    @Test func invalidHTTPResponseFinishesByThrowing() async throws {
        let client = makeClient(protocolClass: FailedUploadURLProtocol.self)

        do {
            _ = try await client.uploadMedia(
                .init(file: Data("media".utf8)),
                mimeType: "image/jpeg",
                progress: { _ in }
            )
            Issue.record("Expected the upload to throw")
        } catch let error as TootSDKError {
            guard case .invalidStatusCode = error else {
                Issue.record("Expected an invalid status code error")
                return
            }
        }
    }

    @Test(arguments: [TransportFailureURLProtocol.self, InvalidJSONURLProtocol.self])
    func transportAndDecodingFailuresFinishByThrowing(protocolClass: URLProtocol.Type) async {
        let client = makeClient(protocolClass: protocolClass)

        await #expect(throws: Error.self) {
            _ = try await client.uploadMedia(
                .init(file: Data("media".utf8)),
                mimeType: "image/jpeg",
                progress: { _ in }
            )
        }
    }

    @Test func cancellingUploadCancelsURLSessionTask() async {
        await SuspendedUploadURLProtocol.reset()

        let client = makeClient(protocolClass: SuspendedUploadURLProtocol.self)
        let upload = Task {
            try await client.uploadMedia(
                .init(file: Data("media".utf8)),
                mimeType: "image/jpeg",
                progress: { _ in }
            )
        }

        await SuspendedUploadURLProtocol.started.wait()
        upload.cancel()
        _ = await upload.result
        await SuspendedUploadURLProtocol.cancellation.wait()
    }

    private func makeClient(protocolClass: AnyClass) -> TootClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [protocolClass]
        return TootClient(
            session: URLSession(configuration: configuration),
            instanceURL: URL(string: "https://example.com")!
        )
    }
}

private final class ProgressStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = [Double]()

    var values: [Double] {
        lock.withLock { storage }
    }

    func append(_ progress: Double) {
        lock.withLock {
            storage.append(progress)
        }
    }
}
