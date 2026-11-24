//
//  RepositoryTestCase.swift
//  HabiticaTests
//
//  Base for repository tests: fake auth, canned HTTP responses and a wiped in-memory database per test.
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database
@testable import Habitica

final class StubURLProtocol: URLProtocol {
    struct Response {
        var status: Int
        var body: String
        var delay: TimeInterval = 0
    }

    static var responses: [String: Response] = [:]
    static var requests: [URLRequest] = []

    /// Key is "METHOD path", path relative to the API root, e.g. "POST tasks/user".
    static func key(method: String, path: String) -> String {
        return "\(method) \(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))"
    }

    /// The request path below the API root, without query or surrounding slashes.
    static func apiPath(_ request: URLRequest) -> String {
        let path = request.url?.path ?? ""
        guard let root = path.range(of: "/api/v[0-9]+/", options: .regularExpression) else {
            return path
        }
        return String(path[root.upperBound...]).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        var recorded = request
        // URLSession moves the body into a stream, read it back so tests can assert on it
        if recorded.httpBody == nil, let stream = request.httpBodyStream {
            recorded.httpBody = Data(reading: stream)
        }
        let path = StubURLProtocol.apiPath(request)
        // ConfigRepository refetches on every auth change; keep that out of the assertions
        if path != "client-config" {
            StubURLProtocol.requests.append(recorded)
        }
        let stub = StubURLProtocol.responses[StubURLProtocol.key(method: request.httpMethod ?? "GET", path: path)]
            ?? Response(status: 404, body: "{\"success\":false,\"error\":\"NotFound\"}")
        guard let url = request.url,
              let response = HTTPURLResponse(url: url, statusCode: stub.status, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"]) else {
            return
        }
        let deliver = {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: Data(stub.body.utf8))
            self.client?.urlProtocolDidFinishLoading(self)
        }
        if stub.delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + stub.delay, execute: deliver)
        } else {
            deliver()
        }
    }

    override func stopLoading() {}
}

private extension Data {
    init(reading stream: InputStream) {
        self.init()
        stream.open()
        defer { stream.close() }
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read <= 0 { break }
            append(buffer, count: read)
        }
    }
}

/// Records what a repository would show instead of presenting it.
final class RecordingFeedback: RepositoryFeedback {
    var toasts: [(text: String, color: ToastColor)] = []
    var goldEarned: [Float] = []
    var armoires: [ArmoireResponseProtocol] = []
    var hatchedPets: [(pet: PetProtocol, equip: () -> Void)] = []
    var raisedMounts: [(pet: PetProtocol, equip: () -> Void)] = []
    var missingSaddleShown = 0
    var haptics: [Haptic] = []
    var scoreChanges: [ScoreChange] = []
    var levelUps = 0
    var skillsUsed: [(name: String, mana: Int)] = []
    var questDamage: [Float] = []
    var brokenItems: [String] = []
    var selectedClasses: [HabiticaClass] = []

    var toastTexts: [String] { toasts.map(\.text) }
    var nothingShown: Bool {
        toasts.isEmpty && goldEarned.isEmpty && armoires.isEmpty && hatchedPets.isEmpty && raisedMounts.isEmpty && missingSaddleShown == 0
            && scoreChanges.isEmpty && levelUps == 0 && skillsUsed.isEmpty && questDamage.isEmpty && brokenItems.isEmpty && selectedClasses.isEmpty
    }

    func showToast(_ text: String, color: ToastColor, delay: TimeInterval) { toasts.append((text, color)) }
    func showGoldEarned(_ gold: Float) { goldEarned.append(gold) }
    func showArmoire(_ armoire: ArmoireResponseProtocol) { armoires.append(armoire) }
    func showPetHatched(_ pet: PetProtocol, equip: @escaping () -> Void) { hatchedPets.append((pet, equip)) }
    func showMountRaised(_ pet: PetProtocol, equip: @escaping () -> Void) { raisedMounts.append((pet, equip)) }
    func showMissingSaddle() { missingSaddleShown += 1 }
    func haptic(_ haptic: Haptic) { haptics.append(haptic) }
    func showScoreChange(_ change: ScoreChange) { scoreChanges.append(change) }
    func showLevelUp() { levelUps += 1 }
    func showSkillUsed(_ name: String, mana: Int) { skillsUsed.append((name, mana)) }
    func showQuestDamage(_ damage: Float) { questDamage.append(damage) }
    func showItemBroken(_ name: String) { brokenItems.append(name) }
    func showClassSelected(_ habiticaClass: HabiticaClass) { selectedClasses.append(habiticaClass) }
}

private final class InMemoryAuthenticationStorage: AuthenticationStorage {
    var userID: String?
    var apiKey: String?
}

class RepositoryTestCase: XCTestCase {

    let userID = "11111111-2222-3333-4444-555555555555"
    let apiKey = "test-api-key"

    private var originalStorage: AuthenticationStorage?
    private var originalUserID: String?
    private var originalUserKey: String?
    private var originalDefaultsUserID: String?
    private var originalURLConfiguration: URLSessionConfiguration?
    private var originalRetryPolicy = NetworkCall.retryPolicy

    override func setUp() {
        super.setUp()
        StubURLProtocol.responses = [:]
        StubURLProtocol.requests = []

        originalDefaultsUserID = UserDefaults.standard.string(forKey: "currentUserId")
        originalStorage = AuthenticationManager.shared.storage
        originalUserID = NetworkAuthenticationManager.shared.currentUserId
        originalUserKey = NetworkAuthenticationManager.shared.currentUserKey
        // never touch the simulator keychain
        AuthenticationManager.shared.storage = InMemoryAuthenticationStorage()
        AuthenticationManager.shared.setAuthentication(userId: userID, key: apiKey)

        originalRetryPolicy = NetworkCall.retryPolicy
        NetworkCall.retryPolicy = { (10, 0, 0) }
        originalURLConfiguration = AuthenticatedCall.defaultConfiguration.urlConfiguration
        let stubbed = URLSessionConfiguration.ephemeral
        stubbed.protocolClasses = [StubURLProtocol.self]
        AuthenticatedCall.defaultConfiguration.urlConfiguration = stubbed

        resetDatabase()
    }

    private func resetDatabase() {
        BaseLocalRepository().clearDatabase()
    }

    override func tearDown() {
        resetDatabase()
        if let original = originalURLConfiguration {
            AuthenticatedCall.defaultConfiguration.urlConfiguration = original
        }
        NetworkCall.retryPolicy = originalRetryPolicy
        AuthenticationManager.shared.storage = originalStorage
        AuthenticationManager.shared.currentUserIDProperty.value = originalUserID
        NetworkAuthenticationManager.shared.currentUserId = originalUserID
        NetworkAuthenticationManager.shared.currentUserKey = originalUserKey
        UserDefaults.standard.set(originalDefaultsUserID, forKey: "currentUserId")
        super.tearDown()
    }

    // MARK: Stubbing

    /// `delay` holds the answer back, to check what happens while a request is in flight.
    func stub(_ method: String, _ path: String, status: Int = 200, data: String = "{}", delay: TimeInterval = 0) {
        StubURLProtocol.responses[StubURLProtocol.key(method: method, path: path)] =
            StubURLProtocol.Response(status: status, body: "{\"success\":\(status < 300),\"data\":\(data)}", delay: delay)
    }

    func stubRaw(_ method: String, _ path: String, status: Int = 200, body: String) {
        StubURLProtocol.responses[StubURLProtocol.key(method: method, path: path)] = StubURLProtocol.Response(status: status, body: body)
    }

    func fixture(_ name: String) throws -> String {
        let url = try XCTUnwrap(Bundle(for: RepositoryTestCase.self).url(forResource: name, withExtension: "json"))
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// The fixture user as JSON, owned by the test user.
    func userJSON() throws -> String {
        return try fixture("user").replacingOccurrences(of: "\"MOCK\"", with: "\"\(userID)\"")
    }

    /// Saves the fixture user (balance 20.75, a few pets, mounts and items) for the test user.
    func storeFixtureUser() throws {
        let user = try JSONDecoder().decode(APIUser.self, from: Data(try userJSON().utf8))
        UserLocalRepository().save(user)
    }

    /// Saves pet and mount content, e.g. ["Wolf-Base"].
    func storeAnimals(_ keys: [String]) throws {
        let animals = keys.map { key -> String in
            let parts = key.split(separator: "-")
            return #""\#(key)":{"key":"\#(key)","egg":"\#(parts[0])","potion":"\#(parts[1])","type":"drop","text":"\#(key)"}"#
        }.joined(separator: ",")
        let json = #"{"petInfo":{\#(animals)},"mountInfo":{\#(animals)}}"#
        ContentLocalRepository().save(try JSONDecoder().decode(APIContent.self, from: Data(json.utf8)))
    }

    var requestedPaths: [String] {
        return StubURLProtocol.requests.map { "\($0.httpMethod ?? "") \(StubURLProtocol.apiPath($0))" }
    }

    func requestBody(_ index: Int = 0) throws -> [String: Any] {
        let data = try XCTUnwrap(StubURLProtocol.requests[index].httpBody)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    // MARK: Waiting

    /// Returns the first value the signal sends, failing if none arrives in time.
    @discardableResult
    func firstValue<T>(_ signal: Signal<T, Never>, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> T? {
        let expectation = expectation(description: "signal value")
        var result: T?
        let disposable = signal.take(first: 1).observeValues { value in
            result = value
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
        disposable?.dispose()
        return result
    }

    func firstValue<T, E>(_ producer: SignalProducer<T, E>, timeout: TimeInterval = 5) -> T? {
        let expectation = expectation(description: "producer value")
        var result: T?
        let disposable = producer.take(first: 1).startWithResult { value in
            result = try? value.get()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
        disposable.dispose()
        return result
    }

    /// Asserts the signal ends without sending anything (e.g. a call skipped by a guard).
    func assertEmpty<T>(_ signal: Signal<T, Never>, file: StaticString = #filePath, line: UInt = #line) {
        var values = 0
        let ended = expectation(description: "signal ended")
        signal.observe { event in
            if case .value = event {
                values += 1
            } else {
                ended.fulfill()
            }
        }
        wait(for: [ended], timeout: 1)
        XCTAssertEqual(values, 0, file: file, line: line)
    }

    /// Lets queued network work and main-queue callbacks run.
    func drain(_ seconds: TimeInterval = 0.3) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Waits until `count` requests were made.
    func waitForRequests(_ count: Int, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        while StubURLProtocol.requests.count < count && Date() < deadline {
            drain(0.05)
        }
        XCTAssertGreaterThanOrEqual(StubURLProtocol.requests.count, count, "expected \(count) requests, got \(requestedPaths)", file: file, line: line)
    }
}
