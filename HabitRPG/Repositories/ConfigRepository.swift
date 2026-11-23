import Foundation
import Habitica_API_Client
import Habitica_Models
import ReactiveSwift

extension AnyClientConfigKey {
    static let supportEmail = ClientConfigKey("supportEmail", default: "admin@habitica.com")
    static let instagramUsername = ClientConfigKey("instagramUsername", default: Constants.defaultInstagramUsername)
    static let appstoreUrl = ClientConfigKey("appstoreURL", default: Constants.defaultAppstoreUrl)
    static let feedbackURL = ClientConfigKey("feedbackURL", default: "https://docs.google.com/forms/d/e/1FAIpQLScPhrwq_7P1C6PTrI3lbvTsvqGyTNnGzp1ugi1Ml0PFee_p5g/viewform?usp=sf_link")
    
    static let maxChatLength = ClientConfigKey("maxChatLength", default: 3000)
    static let lastVersionNumber = ClientConfigKey<String?>("lastVersionNumber", default: nil)
    static let lastVersionCode = ClientConfigKey<Int>("lastVersionCode", default: 0)
    static let randomizeAvatar = ClientConfigKey("randomizeAvatar", default: false)
    static let showSubscriptionBanner = ClientConfigKey("showSubscriptionBanner", default: false)
    // JSONValue fields so an extra non-string field doesn't drop the whole value, like the old NSDictionary parsing
    static let knownIssues = ClientConfigKey<[[String: JSONValue]]>("knownIssues", default: [])
    static let maintenanceData = ClientConfigKey<[String: JSONValue]>("maintenanceData", default: [:])
    static let surveyURL = ClientConfigKey("surveyURL", default: "")

    static let enableIpadUI = ClientConfigKey("enableIpadUI", default: false)
    static let disableIntroSlides = ClientConfigKey("disableIntroSlides", default: false)
    static let showTaskDetailScreen = ClientConfigKey("showTaskDetailScreen", default: false)
    static let showTaskGraphs = ClientConfigKey("showTaskGraphs", default: false)
    static let enableCronButton = ClientConfigKey("enableCronButton", default: false)
    static let hideChallenges = ClientConfigKey("hideChallenges", default: false)

    static let reviewMaxRequests = ClientConfigKey("reviewMaxRequests", default: 5)
    static let reviewMaxCheckinsSinceFirstRequest = ClientConfigKey("reviewMaxCheckinsSinceFirstRequest", default: 75)
    static let reviewMinCheckinsBetweenRequests = ClientConfigKey("reviewMinCheckinsBetweenRequests", default: 5)

    // App Store product identifiers, so the server has to send iOS values to iOS clients
    static let defaultSubscriptionSku = ClientConfigKey("defaultSubscriptionSku", default: PurchaseHandler.subscriptionIdentifiers[3])
    static let highlightedSubscriptionSku = ClientConfigKey("highlightedSubscriptionSku", default: PurchaseHandler.subscriptionIdentifiers[3])

    static let networkTimeoutSeconds = ClientConfigKey("networkTimeoutSeconds", default: 180)
    static let networkMaxRetries = ClientConfigKey("networkMaxRetries", default: 0)
    static let networkRetryBackoffMillis = ClientConfigKey("networkRetryBackoffMillis", default: 1000)
}

enum TestingLevel: String {
    case production
    case beta
    case staff
    case debug
    case simulator
    
    var isTrustworthy: Bool {
        if self == .production || self == .beta {
            return false
        } else {
            return true
        }
    }
    
    var isDeveloper: Bool {
        if self == .debug || self == .simulator {
            return true
        } else {
            return false
        }
    }
}

class ConfigRepository {
    public static let shared = ConfigRepository()

    private static let configStorageKey = "clientConfig"
    private static let lastFetchStorageKey = "clientConfigLastFetch"
    // Unchanged configs are answered with an empty 304, so checking often is cheap
    private static let refetchInterval: TimeInterval = 15 * 60

    private let userConfig: UserDefaults
    private let contentRepository = ContentRepository()
    private let customRetrieveConfig: ((Bool) -> Signal<[String: JSONValue]?, Never>)?

    private var worldState: WorldStateProtocol?
    private var hasFetchedConfig = false
    
    var onFetchCompleted: (() -> Void)?
    var hasFetched: Bool {
        return hasFetchedConfig
    }
    
    private struct ConfigObserver {
        let key: String
        let notify: (JSONValue?) -> Void
    }

    // Guards config, lastFetch, the fetch state and observers
    private let lock = NSLock()
    private var config: [String: JSONValue]
    private var lastFetch: Date?
    private var lastAttemptInSession: Date?
    private var isFetching = false
    private var refetchPending = false
    private var observers = [UUID: ConfigObserver]()
    private var worldStateDisposable: Disposable?

    var lastFetchDate: Date? {
        return synchronized { lastFetch }
    }

    /// Parameters exist for tests; the app uses the defaults.
    init(userConfig: UserDefaults = .standard,
         notificationCenter: NotificationCenter = .default,
         retrieveConfig: ((Bool) -> Signal<[String: JSONValue]?, Never>)? = nil) {
        self.userConfig = userConfig
        customRetrieveConfig = retrieveConfig
        if let data = userConfig.data(forKey: ConfigRepository.configStorageKey),
           let cachedConfig = try? JSONDecoder().decode([String: JSONValue].self, from: data) {
            config = cachedConfig
        } else {
            config = [:]
        }
        lastFetch = userConfig.object(forKey: ConfigRepository.lastFetchStorageKey) as? Date
        // Targeted values depend on the user, so a login or logout needs a fresh config
        notificationCenter.addObserver(forName: .authenticationChanged, object: nil, queue: nil) {[weak self] _ in
            self?.refetchAfterAuthenticationChange()
        }
    }

    private func refetchAfterAuthenticationChange() {
        // Before the launch fetch there is nothing stale, and launch args set credentials before the network client and database exist
        let hasStarted = synchronized { isFetching || lastAttemptInSession != nil }
        if hasStarted {
            fetchRemoteConfig(force: true)
        }
    }

    /// `force` skips the refetch interval, e.g. when the logged in user changes and targeted values might differ.
    func fetchRemoteConfig(force: Bool = false) {
        let ignoreEtag: Bool? = synchronized {
            if isFetching {
                // The running request may have been sent with the previous credentials
                refetchPending = refetchPending || force
                return nil
            }
            if !force, let lastAttempt = lastAttemptInSession, -lastAttempt.timeIntervalSinceNow < ConfigRepository.refetchInterval {
                return nil
            }
            isFetching = true
            // Without a cached config a 304 would leave us on defaults
            return config.isEmpty
        }
        guard let ignoreEtag = ignoreEtag else {
            return
        }
        (customRetrieveConfig ?? contentRepository.retrieveClientConfig)(ignoreEtag).observe {[weak self] event in
            guard let self = self else {
                return
            }
            if case .value(let config) = event, let config = config {
                self.update(config: config)
            } else if event.isTerminating {
                self.finishFetch()
            }
        }
    }

    func startWorldStateUpdates() {
        if worldStateDisposable == nil {
            worldStateDisposable = contentRepository.getWorldState().on(value: {[weak self] state in
                self?.worldState = state
                var hasAprilFools = false
                for event in state.events {
                    if let aprilFools = event.aprilFools {
                        EventHelper.setup(event: aprilFools, endDate: event.end)
                        hasAprilFools = true
                    }
                }
                if !hasAprilFools {
                    EventHelper.disableAll()
                }
            }).start()
        }
    }

    private func finishFetch() {
        let shouldRefetch: Bool = synchronized {
            isFetching = false
            lastAttemptInSession = Date()
            defer { refetchPending = false }
            return refetchPending
        }
        // Also set on 304 and failures, the launch screen only waits for an answer, cached or not
        hasFetchedConfig = true
        let completion = onFetchCompleted
        onFetchCompleted = nil
        completion?()
        if shouldRefetch {
            fetchRemoteConfig(force: true)
        }
    }

    func update(config newConfig: [String: JSONValue]) {
        let now = Date()
        let (oldConfig, currentObservers) = synchronized {
            let oldConfig = config
            config = newConfig
            lastFetch = now
            return (oldConfig, Array(observers.values))
        }

        if let data = try? JSONEncoder().encode(newConfig) {
            userConfig.set(data, forKey: ConfigRepository.configStorageKey)
        }
        userConfig.set(now, forKey: ConfigRepository.lastFetchStorageKey)

        for observer in currentObservers where oldConfig[observer.key] != newConfig[observer.key] {
            observer.notify(newConfig[observer.key])
        }
    }

    private func synchronized<T>(_ block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }

    var testingLevel: TestingLevel {
        #if targetEnvironment(simulator)
            return .simulator
        #else
        let value = Bundle.main.infoDictionary?["TESTING_LEVEL"] as? String
        switch value {
        case "debug":
            return .debug
        case "staff":
            return .staff
        case "beta":
            return .beta
        default:
            return .production
        }
#endif
    }

    /// Developer flag: ignore the server config and use every key's default
    static let useDefaultsFlag = "useDefaultClientConfig"

    func setDeveloperFlag(_ isEnabled: Bool, forKey key: String) {
        userConfig.set(isEnabled, forKey: key)
    }

    func value<T>(for key: ClientConfigKey<T>) -> T {
        let raw = synchronized { config[key.key] }
        return decode(raw, for: key)
    }

    /// Emits the current value immediately (unless `includingCurrent` is false) and then again whenever a fetch changes it.
    func values<T>(for key: ClientConfigKey<T>, includingCurrent: Bool = true) -> AsyncStream<T> {
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let id = UUID()
            synchronized {
                observers[id] = ConfigObserver(key: key.key) {[weak self] raw in
                    guard let self = self else {
                        return
                    }
                    continuation.yield(self.decode(raw, for: key))
                }
                // Yield while holding the lock so no update can slip in between registering and the initial value
                if includingCurrent {
                    continuation.yield(decode(config[key.key], for: key))
                }
            }
            continuation.onTermination = {[weak self] _ in
                guard let self = self else {
                    return
                }
                self.synchronized {
                    self.observers[id] = nil
                }
            }
        }
    }

    /// Calls `onChange` on the main actor with each new value of `key` until the returned task is cancelled.
    @discardableResult
    func observe<T>(_ key: ClientConfigKey<T>, includingCurrent: Bool = true, onChange: @escaping @MainActor (T) -> Void) -> Task<Void, Never> {
        // Not dropFirst: with a newest-only buffer a change arriving before the task starts would replace the current value and get dropped
        let stream = values(for: key, includingCurrent: includingCurrent)
        return Task { @MainActor in
            for await value in stream {
                onChange(value)
            }
        }
    }

    private func decode<T>(_ raw: JSONValue?, for key: ClientConfigKey<T>) -> T {
        #if DEBUG
        if testingLevel.isDeveloper && userConfig.bool(forKey: ConfigRepository.useDefaultsFlag) {
            return key.defaultValue
        }
        #endif
        guard let raw = raw, let value = try? raw.decodeAllowingJSONString(T.self) else {
            return key.defaultValue
        }
        return value
    }

    func activePromotion() -> HabiticaPromotion? {
        var promo: HabiticaPromotion?
        if let active = userConfig.string(forKey: "activePromo"), testingLevel != .production && testingLevel != .beta {
            let today = Calendar.current.startOfDay(for: Date())
            return HabiticaPromotionType.getPromoFromKey(key: active,
                                                         startDate: Calendar.current.date(byAdding: .day, value: -3, to: today),
                                                         endDate: Calendar.current.date(byAdding: .day, value: 4, to: today))
        }
        for event in worldState?.events ?? [] where HabiticaPromotionType.getPromoFromKey(key: event.promo ?? event.eventKey ?? "", startDate: event.start, endDate: event.end) != nil {
            promo = HabiticaPromotionType.getPromoFromKey(key: event.promo ?? event.eventKey ?? "", startDate: event.start, endDate: event.end)
        }
        if let promo = promo, promo.endDate > Date() {
            return promo
        } else {
            return nil
        }
    }
    
    func enableIPadUI() -> Bool {
        if isOnMac {
            return true
        }
        return value(for: .enableIpadUI)
    }
    
    func shopSpriteSuffix() -> String? {
        for event in worldState?.events ?? [] where event.npcImageSuffix?.isEmpty == false {
            return event.npcImageSuffix
        }
        return nil
    }
    
    let isOnMac: Bool = {
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return ProcessInfo.processInfo.isiOSAppOnMac
        #endif
    }()
}
