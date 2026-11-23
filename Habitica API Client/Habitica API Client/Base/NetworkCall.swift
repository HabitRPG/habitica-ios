//
//  NetworkCall.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import Foundation
import ReactiveSwift

open class NetworkCall {
    
    public let configuration: ServerConfigurationProtocol
    public let endpoint: String
    public let httpMethod: String
    public let postData: Data?
    public let httpHeaders: [String: String]?
    
    open var urlString: String
    
    public let dataTaskSignal: Signal<URLSessionDataTask, Never>
    
    public let responseSignal: Signal<URLResponse, Never>
    public let httpResponseSignal: Signal<HTTPURLResponse, Never>
    public let dataSignal: Signal<Data?, Never>
    
    public let errorSignal: Signal<NSError, Never>
    public let serverErrorSignal: Signal<NSError, Never>
    public let errorDataSignal: Signal<Data, Never>
    
    let dataTaskProperty = MutableProperty<URLSessionDataTask?>(nil)
    let responseProperty = MutableProperty<URLResponse?>(nil)
    let dataProperty = MutableProperty<Data?>(nil)
    
    let errorProperty = MutableProperty<NSError?>(nil)
    let serverErrorProperty = MutableProperty<NSError?>(nil)
    let errorResponseProperty = MutableProperty<URLResponse?>(nil)
    let errorDataProperty = MutableProperty<Data?>(nil)
    
    let fireProperty = MutableProperty(())
    
    var ignoreEtag = false
    
    public init(configuration: ServerConfigurationProtocol,
                httpMethod: String = "GET",
                httpHeaders: [String: String]? = [:],
                endpoint: String, postData: Data?,
                networkErrorHandler: NetworkErrorHandler? = nil,
                ignoreEtag: Bool = false) {
        self.configuration = configuration
        self.httpMethod = httpMethod
        self.httpHeaders = httpHeaders
        self.endpoint = endpoint
        self.postData = postData
        self.ignoreEtag = ignoreEtag
        
        urlString = NetworkCall.configurationToBaseUrlString(configuration) + endpoint
        
        dataTaskSignal = dataTaskProperty.signal.skipNil()
        responseSignal = responseProperty.signal.skipNil()
        httpResponseSignal = responseSignal.map({ $0 as? HTTPURLResponse }).skipNil().on(value: { response in
            if response.allHeaderFields.keys.contains("Etag") {
                guard let etag = response.allHeaderFields["Etag"] as? String else {
                    return
                }
                guard let urlString = response.url?.absoluteString else {
                    return
                }
                if HabiticaServerConfig.etag(for: urlString) != etag {
                    UserDefaults.standard.set(etag, forKey: "etag\(urlString)")
                    HabiticaServerConfig.setEtag(etag, for: urlString)
                }
            }
        })
        dataSignal = dataProperty.signal
        
        errorDataSignal = errorDataProperty.signal.skipNil()
        errorSignal = errorProperty.signal.skipNil()
        // 304 answers our own If-None-Match: nothing changed, not an error
        serverErrorSignal = httpResponseSignal.filter({ $0.statusCode >= 300 && $0.statusCode != 304 }).map({ NSError(domain: "Server", code: $0.statusCode, userInfo: ["url": $0.url?.absoluteString as Any]) })
        
        dataTaskSignal.observeValues { task in
            task.resume()
        }
        fire()
    }
    
    // One session per URLSessionConfiguration so connections and TLS handshakes are reused across calls.
    private static let sessionLock = NSLock()
    private static var sessions = [ObjectIdentifier: URLSession]()
    
    private static func session(for urlConfiguration: URLSessionConfiguration) -> URLSession {
        sessionLock.lock()
        defer { sessionLock.unlock() }
        let key = ObjectIdentifier(urlConfiguration)
        if let session = sessions[key] {
            return session
        }
        let session = URLSession(configuration: urlConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        sessions[key] = session
        return session
    }
    
    public static var retryPolicy: () -> (timeoutSeconds: Int, maxRetries: Int, backoffMillis: Int) = { (180, 0, 1000) }
    private static let retryableStatusCodes: Set<Int> = [502, 503, 504]

    static func clampedRetryPolicy() -> (timeout: TimeInterval, maxRetries: Int, backoff: TimeInterval) {
        let policy = retryPolicy()
        return (TimeInterval(min(max(policy.timeoutSeconds, 10), 600)),
                min(max(policy.maxRetries, 0), 5),
                TimeInterval(min(max(policy.backoffMillis, 0), 30_000)) / 1000)
    }

    open func fire() {
        guard let request = mutableRequest() else {
            return
        }
        let policy = NetworkCall.clampedRetryPolicy()
        perform(request as URLRequest, retriesLeft: httpMethod == "GET" ? policy.maxRetries : 0, backoff: policy.backoff,
                deadline: Date().addingTimeInterval(policy.timeout))
        DispatchQueue.main.asyncAfter(deadline: .now() + policy.timeout) {[weak self] in
            if let task = self?.dataTaskProperty.value, task.state == .running {
                task.cancel()
            }
        }
    }

    private func perform(_ request: URLRequest, retriesLeft: Int, backoff: TimeInterval, deadline: Date) {
        let session = NetworkCall.session(for: configuration.urlConfiguration)
        dataTaskProperty.value = session.dataTask(with: request) { (data, response, error) in
            let isCancelled = (error as? URLError)?.code == .cancelled
            let isRetryable = error != nil ? !isCancelled
                : NetworkCall.retryableStatusCodes.contains((response as? HTTPURLResponse)?.statusCode ?? 0)
            if retriesLeft > 0 && isRetryable && Date().addingTimeInterval(backoff) < deadline {
                DispatchQueue.main.asyncAfter(deadline: .now() + backoff) {
                    self.perform(request, retriesLeft: retriesLeft - 1, backoff: backoff * 2, deadline: deadline)
                }
                return
            }
            self.errorProperty.value = error as NSError?
            self.responseProperty.value = response
            if error != nil {
                self.errorDataProperty.value = data
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 300 {
                self.errorDataProperty.value = data
            } else {
                self.dataProperty.value = data
            }
            self.endCall()
        }
    }
    
    open func endCall() {
        
    }
    
    open func mutableRequest() -> NSMutableURLRequest? {
        var request: NSMutableURLRequest?
        if let url = URL(string: urlString) {
            request = NSMutableURLRequest(url: url)
        }
        request = applyHeaders(request)
        request = applyHttpMethod(request)
        request = applyBody(request)
        return request
    }
    
    public static func configurationToBaseUrlString(_ configuration: ServerConfigurationProtocol) -> String {
        let baseUrlString = "\(configuration.scheme)://\(configuration.host)"
        if let apiRoute = configuration.apiBaseRoute {
            return "\(baseUrlString)/\(apiRoute)/"
        } else {
            return "\(baseUrlString)/"
        }
    }
    
    open func applyHeaders(_ request: NSMutableURLRequest?) -> NSMutableURLRequest? {
        if let mutableRequest = request {
            if let headers = httpHeaders {
                for key in headers.keys {
                    if let header = headers[key] {
                        mutableRequest.addValue(header, forHTTPHeaderField: key)
                    }
                }
            }
            if !ignoreEtag {
                if let urlString = request?.url?.absoluteString {
                    if let etag = HabiticaServerConfig.etag(for: urlString) {
                        mutableRequest.addValue(etag, forHTTPHeaderField: "If-None-Match")
                    }
                }
            }
            return mutableRequest
        }
        return nil
    }
    
    open func applyHttpMethod(_ request: NSMutableURLRequest?) -> NSMutableURLRequest? {
        if let mutableRequest = request {
            mutableRequest.httpMethod = httpMethod
            return mutableRequest
        }
        return nil
    }
    
    open func applyBody(_ request: NSMutableURLRequest?) -> NSMutableURLRequest? {
        if let mutableRequest = request {
            mutableRequest.httpBody = postData
            return mutableRequest
        }
        return nil
    }
}

precedencegroup ForwardApplication {
    associativity: left
}

infix operator <^>: ForwardApplication

func <^> <A, B, C>(function1: @escaping (A) -> B?, function2: @escaping (B) -> C) -> (A) -> C? {
    return { first in
        if let second = function1(first) {
            return function2(second)
        } else {
            return nil
        }
    }
}
