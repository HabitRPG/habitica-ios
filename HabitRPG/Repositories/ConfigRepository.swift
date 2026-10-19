import Foundation
import Habitica_API_Client
import Habitica_Models

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
    static let knownIssues = ClientConfigKey<[String]>("knownIssues", default: [])
    static let maintenanceData = ClientConfigKey<[String: String]>("maintenanceData", default: [:])
    static let surveyURL = ClientConfigKey("surveyURL", default: "")

    static let enableIpadUI = ClientConfigKey("enableIpadUI", default: false)
    static let disableIntroSlides = ClientConfigKey("disableIntroSlides", default: false)
    static let showTaskDetailScreen = ClientConfigKey("showTaskDetailScreen", default: false)
    static let showTaskGraphs = ClientConfigKey("showTaskGraphs", default: false)
    static let enableCronButton = ClientConfigKey("enableCronButton", default: false)
    static let hideChallenges = ClientConfigKey("hideChallenges", default: false)
}

extension Notification.Name {
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

    private let userConfig = UserDefaults.standard
    private let contentRepository = ContentRepository()

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

    // Guards config, lastFetch and observers
    private let lock = NSLock()
    private var config: [String: JSONValue]
    private var lastFetch: Date?
    private var lastFetchInSession: Date?
    private var observers = [UUID: ConfigObserver]()

    var lastFetchDate: Date? {
        return synchronized { lastFetch }
    }

    init() {
        if let data = userConfig.data(forKey: ConfigRepository.configStorageKey),
           let cachedConfig = try? JSONDecoder().decode([String: JSONValue].self, from: data) {
            config = cachedConfig
        } else {
            config = [:]
        }
        lastFetch = userConfig.object(forKey: ConfigRepository.lastFetchStorageKey) as? Date
    }

    @objc
    func fetchremoteConfig() {
        if lastFetchInSession == nil || (lastFetchInSession?.timeIntervalSinceNow ?? 0) < (24 * 60 * 60) {
            contentRepository.retrieveClientConfig().on(value: {[weak self] config in
                guard let self = self else {
                    return
                }
                if let config = config {
                    self.update(config: config)
                }
                self.hasFetchedConfig = true
                if let call = self.onFetchCompleted {
                    call()
                }
            }).observeCompleted {}
            
            contentRepository.getWorldState().on(value: {[weak self] state in
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

    private func update(config newConfig: [String: JSONValue]) {
        let now = Date()
        let (oldConfig, currentObservers) = synchronized {
            let oldConfig = config
            config = newConfig
            lastFetch = now
            lastFetchInSession = now
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

    func setDeveloperFlag(_ isEnabled: Bool, forKey key: String) {
        UserDefaults.standard.set(isEnabled, forKey: key)
    }

    func value<T>(for key: ClientConfigKey<T>) -> T {
        let raw = synchronized { config[key.key] }
        return decode(raw, for: key)
    }

    /// Emits the current value immediately and then again whenever a fetch changes it.
    func values<T>(for key: ClientConfigKey<T>) -> AsyncStream<T> {
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
                continuation.yield(decode(config[key.key], for: key))
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

    private func decode<T>(_ raw: JSONValue?, for key: ClientConfigKey<T>) -> T {
        #if DEBUG
        if testingLevel.isDeveloper {
            return key.defaultValue
        }
        #endif
        guard let raw = raw, let value = try? raw.decode(T.self) else {
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
        return false
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
