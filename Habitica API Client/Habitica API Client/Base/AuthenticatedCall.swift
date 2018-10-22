//
//  AuthenticatedCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import ReactiveSwift
import Result
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public class AuthenticatedCall: JsonNetworkCall {
    public static var errorHandler: NetworkErrorHandler?
    public static var defaultConfiguration = HabiticaServerConfig.current
    private var debugHandler: DebugOutputHandler?
    fileprivate static let apiKeyHeader = "x-api-key"
    fileprivate static let apiUserIdHeader = "x-api-user"
    fileprivate static let clientHeader = "x-client"
    
    private init(configuration: ServerConfigurationProtocol? = nil, httpMethod: String, httpHeaders: Dictionary<String, String>?, endpoint: String, postData: Data?, stubHolder: StubHolderProtocol?) {
        super.init(configuration: configuration ?? AuthenticatedCall.defaultConfiguration, httpMethod: httpMethod, httpHeaders: httpHeaders, endpoint: endpoint, postData: postData, stubHolder: stubHolder)
    }
    
    init(configuration: ServerConfigurationProtocol? = nil, httpMethod: HTTPMethod, httpHeaders: Dictionary<String, String>? = AuthenticatedCall.jsonHeaders(), endpoint: String, postData: Data? = nil, stubHolder: StubHolderProtocol? = nil) {
        super.init(configuration: configuration ?? AuthenticatedCall.defaultConfiguration, httpMethod: httpMethod.rawValue, httpHeaders: httpHeaders, endpoint: endpoint, postData: postData, stubHolder: stubHolder)
        debugHandler = DebugOutputHandler(httpMethod: httpMethod, url: urlString(endpoint))
        
        debugHandler?.observe(call: self)
        
        setupErrorHandler()
    }
    
    open static override func jsonHeaders() -> Dictionary<String, String> {
        var headers = super.jsonHeaders()
        if let apiKey = NetworkAuthenticationManager.shared.currentUserKey, let userId = NetworkAuthenticationManager.shared.currentUserId {
            headers[AuthenticatedCall.apiKeyHeader] = apiKey
            headers[AuthenticatedCall.apiUserIdHeader] = userId
        }
        headers[AuthenticatedCall.clientHeader] = "habitica-ios"
        return headers
    }
    
    public override func fire() {
        debugHandler?.startNetworkCall()
        super.fire()
    }
    
    func setupErrorHandler() {
        AuthenticatedCall.errorHandler?.observe(signal: Signal<NSError, NoError>.merge([serverErrorSignal, errorSignal]))
    }
    
}
