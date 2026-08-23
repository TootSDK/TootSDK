import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class SuccessfulUploadURLProtocol: URLProtocol, @unchecked Sendable {
    private static let requestStorage = RequestStorage()

    static var lastRequest: URLRequest? {
        requestStorage.value
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.requestStorage.value = request
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(#"{"id":"media-id","url":"https://example.com/media"}"#.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class FailedUploadURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class TransportFailureURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        client?.urlProtocol(self, didFailWithError: URLError(.networkConnectionLost))
    }

    override func stopLoading() {}
}

final class InvalidJSONURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("not JSON".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class SuspendedUploadURLProtocol: URLProtocol, @unchecked Sendable {
    static let started = CancellationSignal()
    static let cancellation = CancellationSignal()

    static func reset() async {
        await started.reset()
        await cancellation.reset()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Task {
            await Self.started.signal()
        }
    }

    override func stopLoading() {
        Task {
            await Self.cancellation.signal()
        }
    }
}

private final class RequestStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var request: URLRequest?

    var value: URLRequest? {
        get {
            lock.withLock { request }
        }
        set {
            lock.withLock { request = newValue }
        }
    }
}

actor CancellationSignal {
    private var continuation: CheckedContinuation<Void, Never>?
    private var wasSignalled = false

    func wait() async {
        if wasSignalled {
            return
        }
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func signal() {
        wasSignalled = true
        continuation?.resume()
        continuation = nil
    }

    func reset() {
        continuation = nil
        wasSignalled = false
    }
}
