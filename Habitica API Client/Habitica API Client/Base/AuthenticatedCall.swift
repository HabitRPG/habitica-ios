//
//  AuthenticatedCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public class AuthenticatedCall: JsonNetworkCall {
    fileprivate static let apiKeyHeader = "x-api-key"
    fileprivate static let apiUserIdHeader = "x-api-user"
    fileprivate static let clientHeader = "x-client"
    fileprivate static let stagingKey = ""
    
    public lazy var errorJsonSignal: Signal<[String: Any], Never> = self.errorDataSignal
        .map(JsonDataHandler.serialize).map({ json in
            return json as? [String: Any]
        }).skipNil()
    
    public static var errorHandler: NetworkErrorHandler?
    public static var defaultConfiguration = HabiticaServerConfig.current
    public static var notificationListener: (([NotificationProtocol]?) -> Void)?
    public static var indicatorController: NetworkIndicatorController?
    
    private var debugHandler = DebugOutputHandler()
    var customErrorHandler: NetworkErrorHandler?
    var needsAuthentication = true
    let queue = DispatchQueue(label: "work", qos: .userInteractive)
    private init(configuration: ServerConfigurationProtocol? = nil,
                 httpMethod: String,
                 httpHeaders: [String: String]?,
                 endpoint: String,
                 postData: Data?, ignoreEtag: Bool = false) {
        super.init(configuration: configuration ?? AuthenticatedCall.defaultConfiguration,
                   httpMethod: httpMethod,
                   httpHeaders: httpHeaders,
                   endpoint: endpoint,
                   postData: postData,
                   ignoreEtag: ignoreEtag)
    }
    
    init(configuration: ServerConfigurationProtocol? = nil,
         httpMethod: HTTPMethod, httpHeaders: [String: String]? = AuthenticatedCall.jsonHeaders(),
         endpoint: String, postData: Data? = nil,
         errorHandler: NetworkErrorHandler? = nil,
         needsAuthentication: Bool = true, ignoreEtag: Bool = false) {
        self.needsAuthentication = needsAuthentication
        
        super.init(configuration: configuration ?? AuthenticatedCall.defaultConfiguration,
                   httpMethod: httpMethod.rawValue,
                   httpHeaders: httpHeaders,
                   endpoint: endpoint,
                   postData: postData,
                   ignoreEtag: ignoreEtag)
        
        customErrorHandler = errorHandler
        setupErrorHandler()
    }
    
    public static override func jsonHeaders() -> [String: String] {
            var headers = super.jsonHeaders()
            if let apiKey = NetworkAuthenticationManager.shared.currentUserKey, let userId = NetworkAuthenticationManager.shared.currentUserId {
                headers[AuthenticatedCall.apiKeyHeader] = apiKey
                headers[AuthenticatedCall.apiUserIdHeader] = userId
            }
            headers[AuthenticatedCall.clientHeader] = "habitica-ios"
            headers["Authorization"] = "Basic YWRtaW46WkY3M1cwSUpXVUFWOTgzNA=="
            return headers
        
    }
    
    public override func fire() {
        queue.async {
            if self.needsAuthentication {
                if NetworkAuthenticationManager.shared.currentUserId == nil {
                    logger.log("User ID is not set in authentication")
                    return
                }
            }
            self.debugHandler.httpMethod = self.httpMethod
            self.debugHandler.url = self.urlString
            self.debugHandler.observe(call: self)
            self.debugHandler.startNetworkCall()
            AuthenticatedCall.indicatorController?.beginNetworking()
            super.fire()
        }
    }
    
    public override func endCall() {
        queue.async {
            AuthenticatedCall.indicatorController?.endNetworking()
        }
    }
    
    func setupErrorHandler() {
        let errorHandler = customErrorHandler ?? AuthenticatedCall.errorHandler
        errorHandler?.observe(signal: Signal<NSError, Never>.merge([serverErrorSignal, errorSignal]))
    }
    
}
