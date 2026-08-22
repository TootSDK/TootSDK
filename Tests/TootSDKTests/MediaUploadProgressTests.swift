import Foundation
import Testing

@testable import TootSDK

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

@Suite struct MediaUploadProgressTests {
    @Test func progressIsMonotonicAndClamped() async throws {
        let (stream, continuation) = AsyncThrowingStream<MediaUploadEvent, Error>.makeStream()
        let delegate = MediaUploadProgressDelegate(continuation: continuation)
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

        let events = try await collect(stream)
        #expect(events.progressValues == [0.25, 1])
    }

    @Test func successfulUploadEmitsProgressAndCompletionWithoutChangingExistingUpload() async throws {
        let client = makeClient(protocolClass: SuccessfulUploadURLProtocol.self)
        let params = UploadMediaAttachmentParams(file: Data("media".utf8), description: "Description")

        let events = try await collect(client.uploadMediaWithProgress(params, mimeType: "image/jpeg"))
        #expect(events.progressValues.first == 0)
        #expect(events.progressValues.last == 1)
        #expect(events.progressValues == events.progressValues.sorted())
        #expect(events.completedAttachments.count == 1)
        #expect(events.isCompletionAfterProgressFinished)
        #expect(SuccessfulUploadURLProtocol.lastRequest?.httpBody == nil)

        let completed = try #require(events.completedAttachment)
        #expect(completed.id == "media-id")
        guard case .uploaded = completed.state else {
            Issue.record("Expected an uploaded attachment")
            return
        }

        let existingResult = try await client.uploadMedia(params, mimeType: "image/jpeg")
        #expect(existingResult.id == "media-id")
        #expect(SuccessfulUploadURLProtocol.lastRequest?.httpMethod == "POST")
        #expect(SuccessfulUploadURLProtocol.lastRequest?.url?.path == "/api/v2/media")
        #expect(SuccessfulUploadURLProtocol.lastRequest?.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data") == true)
    }

    @Test func invalidHTTPResponseFinishesByThrowing() async throws {
        let client = makeClient(protocolClass: FailedUploadURLProtocol.self)
        let stream = client.uploadMediaWithProgress(.init(file: Data("media".utf8)), mimeType: "image/jpeg")

        do {
            _ = try await collect(stream)
            Issue.record("Expected the upload stream to throw")
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
        let stream = client.uploadMediaWithProgress(.init(file: Data("media".utf8)), mimeType: "image/jpeg")

        await #expect(throws: Error.self) {
            _ = try await collect(stream)
        }
    }

    @Test func cancellingConsumerCancelsUploadTask() async {
        let client = makeClient(protocolClass: SuspendedUploadURLProtocol.self)
        let stream = client.uploadMediaWithProgress(.init(file: Data("media".utf8)), mimeType: "image/jpeg")
        let consumer = Task {
            for try await _ in stream {}
        }

        await SuspendedUploadURLProtocol.started.wait()
        consumer.cancel()
        _ = await consumer.result
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

    private func collect(_ stream: AsyncThrowingStream<MediaUploadEvent, Error>) async throws -> [MediaUploadEvent] {
        var events = [MediaUploadEvent]()
        for try await event in stream {
            events.append(event)
        }
        return events
    }
}

extension Array where Element == MediaUploadEvent {
    fileprivate var progressValues: [Double] {
        compactMap { event in
            guard case .progress(let progress) = event else {
                return nil
            }
            return progress
        }
    }

    fileprivate var completedAttachment: UploadedMediaAttachment? {
        completedAttachments.first
    }

    fileprivate var completedAttachments: [UploadedMediaAttachment] {
        compactMap { event in
            guard case .completed(let attachment) = event else {
                return nil
            }
            return attachment
        }
    }

    fileprivate var isCompletionAfterProgressFinished: Bool {
        guard count >= 2,
            case .progress(1) = self[count - 2],
            case .completed = last
        else {
            return false
        }
        return true
    }
}
