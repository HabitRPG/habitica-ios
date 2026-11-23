//
//  ClientConfigCallTests.swift
//  HabiticaTests
//
//  Runs RetrieveClientConfigCall through the real NetworkCall stack, with responses served by a URLProtocol stub.
//

import XCTest
import Habitica_Models
import Habitica_API_Client

private final class ClientConfigStub: URLProtocol {
    static var statusCode = 200
    static var headers: [String: String] = [:]
    static var body = Data()
    static var error: Error?
    static var gatewayErrorsBeforeResponse = 0
    static var requests: [URLRequest] = []

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.path.hasSuffix("/client-config") == true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        ClientConfigStub.requests.append(request)
        if let error = ClientConfigStub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let statusCode = ClientConfigStub.gatewayErrorsBeforeResponse > 0 ? 503 : ClientConfigStub.statusCode
        ClientConfigStub.gatewayErrorsBeforeResponse -= 1
        guard let url = request.url, let response = HTTPURLResponse(url: url, statusCode: statusCode,
                                                                     httpVersion: "HTTP/1.1", headerFields: ClientConfigStub.headers) else {
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: ClientConfigStub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

class ClientConfigCallTests: XCTestCase {

    private var originalURLConfiguration: URLSessionConfiguration?
    private var originalRetryPolicy = NetworkCall.retryPolicy
    private var url: String {
        return RetrieveClientConfigCall.configurationToBaseUrlString(AuthenticatedCall.defaultConfiguration) + "client-config"
    }

    override func setUp() {
        super.setUp()
        ClientConfigStub.statusCode = 200
        ClientConfigStub.headers = [:]
        ClientConfigStub.body = Data()
        ClientConfigStub.error = nil
        ClientConfigStub.gatewayErrorsBeforeResponse = 0
        ClientConfigStub.requests = []
        originalRetryPolicy = NetworkCall.retryPolicy
        // defaultConfiguration is shared with the host app, so swap only the session setup and restore it after
        originalURLConfiguration = AuthenticatedCall.defaultConfiguration.urlConfiguration
        let stubbed = URLSessionConfiguration.ephemeral
        stubbed.protocolClasses = [ClientConfigStub.self]
        AuthenticatedCall.defaultConfiguration.urlConfiguration = stubbed
        clearEtag()
    }

    override func tearDown() {
        if let original = originalURLConfiguration {
            AuthenticatedCall.defaultConfiguration.urlConfiguration = original
        }
        NetworkCall.retryPolicy = originalRetryPolicy
        clearEtag()
        super.tearDown()
    }

    private func clearEtag() {
        HabiticaServerConfig.setEtag(nil, for: url)
        UserDefaults.standard.removeObject(forKey: "etag\(url)")
    }

    private struct Result {
        let response: HabiticaResponse<[String: JSONValue]>?
        let serverErrors: [NSError]
    }

    private func fetch(ignoreEtag: Bool = false) -> Result {
        let call = RetrieveClientConfigCall(ignoreEtag: ignoreEtag)
        let done = expectation(description: "response")
        var response: HabiticaResponse<[String: JSONValue]>?
        var serverErrors = [NSError]()
        // Responses are delivered on the main queue, so observing right after init can't miss them
        call.serverErrorSignal.observeValues { serverErrors.append($0) }
        call.habiticaResponseSignal.observeValues {
            response = $0
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        return Result(response: response, serverErrors: serverErrors)
    }

    func testNotModifiedIsNotAnError() {
        HabiticaServerConfig.setEtag("v1", for: url)
        ClientConfigStub.statusCode = 304

        let result = fetch()

        XCTAssertNil(result.response)
        XCTAssertTrue(result.serverErrors.isEmpty, "a 304 would show an error toast on every config check")
        XCTAssertEqual(ClientConfigStub.requests.first?.value(forHTTPHeaderField: "If-None-Match"), "v1")
        XCTAssertEqual(HabiticaServerConfig.etag(for: url), "v1")
    }

    func testOkResponseIsParsedAndStoresEtag() {
        ClientConfigStub.headers = ["Etag": "v2"]
        ClientConfigStub.body = Data("{\"success\":true,\"data\":{\"maxChatLength\":\"500\",\"hideChallenges\":true}}".utf8)

        let result = fetch()

        XCTAssertEqual(result.response?.data?["maxChatLength"], .string("500"))
        XCTAssertEqual(result.response?.data?["hideChallenges"], .bool(true))
        XCTAssertEqual(HabiticaServerConfig.etag(for: url), "v2")
    }

    func testIgnoreEtagSkipsConditionalHeader() {
        HabiticaServerConfig.setEtag("v1", for: url)
        ClientConfigStub.body = Data("{\"success\":true,\"data\":{}}".utf8)

        _ = fetch(ignoreEtag: true)

        XCTAssertNil(ClientConfigStub.requests.first?.value(forHTTPHeaderField: "If-None-Match"))
    }

    func testUnparsableBodyDropsEtag() {
        // Otherwise the next request gets a 304 for a config we never read and the app stays on old values
        ClientConfigStub.headers = ["Etag": "broken"]
        ClientConfigStub.body = Data("<html>proxy page</html>".utf8)

        let result = fetch()

        XCTAssertNil(result.response)
        XCTAssertNil(HabiticaServerConfig.etag(for: url))
        XCTAssertNil(UserDefaults.standard.string(forKey: "etag\(url)"))
    }

    // MARK: - Retries

    private let validBody = Data("{\"success\":true,\"data\":{\"maxChatLength\":1}}".utf8)

    func testGatewayErrorIsRetried() {
        NetworkCall.retryPolicy = { (180, 2, 0) }
        ClientConfigStub.gatewayErrorsBeforeResponse = 2
        ClientConfigStub.body = validBody

        let result = fetch()

        XCTAssertEqual(ClientConfigStub.requests.count, 3)
        XCTAssertEqual(result.response?.data?["maxChatLength"], .int(1))
        XCTAssertTrue(result.serverErrors.isEmpty, "failed attempts that were retried must not show errors")
    }

    func testNoRetriesByDefault() {
        NetworkCall.retryPolicy = { (180, 0, 0) }
        ClientConfigStub.gatewayErrorsBeforeResponse = 1

        let result = fetch()

        XCTAssertEqual(ClientConfigStub.requests.count, 1)
        XCTAssertEqual(result.serverErrors.map(\.code), [503])
    }

    func testRetriesAreCapped() {
        NetworkCall.retryPolicy = { (180, 100, 0) }
        ClientConfigStub.gatewayErrorsBeforeResponse = 100

        _ = fetch()

        XCTAssertEqual(ClientConfigStub.requests.count, 6, "at most 5 retries whatever the server sends")
    }

    func testClientErrorsAreNotRetried() {
        NetworkCall.retryPolicy = { (180, 3, 0) }
        ClientConfigStub.statusCode = 404

        _ = fetch()

        XCTAssertEqual(ClientConfigStub.requests.count, 1)
    }

    func testOfflineIsRetried() {
        NetworkCall.retryPolicy = { (180, 2, 0) }
        ClientConfigStub.error = URLError(.notConnectedToInternet)

        _ = fetch()

        XCTAssertEqual(ClientConfigStub.requests.count, 3)
    }

    func testPostIsNeverRetried() {
        // Repeating a POST like a task score could apply it twice
        NetworkCall.retryPolicy = { (180, 3, 0) }
        ClientConfigStub.gatewayErrorsBeforeResponse = 3
        let call = NetworkCall(configuration: AuthenticatedCall.defaultConfiguration, httpMethod: "POST", endpoint: "client-config", postData: nil)
        let done = expectation(description: "response")
        call.responseSignal.observeValues { _ in done.fulfill() }
        wait(for: [done], timeout: 5)

        XCTAssertEqual(ClientConfigStub.requests.count, 1)
    }

    func testOfflineStillProducesAValue() {
        ClientConfigStub.error = URLError(.notConnectedToInternet)

        let result = fetch()

        XCTAssertNil(result.response, "the launch screen waits for this value, so offline must not hang")
    }
}
