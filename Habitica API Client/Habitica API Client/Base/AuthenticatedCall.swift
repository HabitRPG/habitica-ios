//
//  AuthenticatedCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Keys

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
            return json as? Dictionary<String, Any>
        }).skipNil()

    public static var errorHandler: NetworkErrorHandler?
    public static var defaultConfiguration = HabiticaServerConfig.current
    private var debugHandler: DebugOutputHandler?
    var customErrorHandler: NetworkErrorHandler?
    var needsAuthentication = true
    
    private init(configuration: ServerConfigurationProtocol? = nil,
                 httpMethod: String,
                 httpHeaders: [String: String]?,
                 endpoint: String,
                 postData: Data?,
                 stubHolder: StubHolderProtocol?) {
        super.init(configuration: configuration ?? AuthenticatedCall.defaultConfiguration,
                   httpMethod: httpMethod,
                   httpHeaders: httpHeaders,
                   endpoint: endpoint,
                   postData: postData,
                   stubHolder: stubHolder)
    }
    
    init(configuration: ServerConfigurationProtocol? = nil,
         httpMethod: HTTPMethod, httpHeaders: [String: String]? = AuthenticatedCall.jsonHeaders(),
         endpoint: String, postData: Data? = nil,
         stubHolder: StubHolderProtocol? = nil,
         errorHandler: NetworkErrorHandler? = nil) {
        super.init(configuration: configuration ?? AuthenticatedCall.defaultConfiguration,
                   httpMethod: httpMethod.rawValue,
                   httpHeaders: httpHeaders,
                   endpoint: endpoint,
                   postData: postData,
                   stubHolder: stubHolder)
        
        customErrorHandler = errorHandler
        
        debugHandler = DebugOutputHandler(httpMethod: httpMethod, url: urlString(endpoint))
        debugHandler?.observe(call: self)
        
        setupErrorHandler()
    }
    
    public static override func jsonHeaders() -> [String: String] {
        var headers = super.jsonHeaders()
        if let apiKey = NetworkAuthenticationManager.shared.currentUserKey, let userId = NetworkAuthenticationManager.shared.currentUserId {
            headers[AuthenticatedCall.apiKeyHeader] = apiKey
            headers[AuthenticatedCall.apiUserIdHeader] = userId
        }
        headers["Authorization"] = "Basic \(HabiticaKeys().stagingKey)"
        headers[AuthenticatedCall.clientHeader] = "habitica-ios"
        return headers
    }
    
    public override func fire() {
        if needsAuthentication {
            if NetworkAuthenticationManager.shared.currentUserId == nil {
                return
            }
        }
        debugHandler?.startNetworkCall()
        super.fire()
    }
    
    func setupErrorHandler() {
        let errorHandler = customErrorHandler ?? AuthenticatedCall.errorHandler
        errorHandler?.observe(signal: Signal<NSError, Never>.merge([serverErrorSignal, errorSignal]))
    }
    
}
