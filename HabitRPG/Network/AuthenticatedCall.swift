//
//  AuthenticatedCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork

public class AuthenticatedCall: JsonNetworkCall {
    fileprivate static let apiKeyHeader = "x-api-key"
    fileprivate static let apiUserIdHeader = "x-api-user"
    
    public override init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: Dictionary<String, String>? = AuthenticatedCall.jsonHeaders(), endpoint: String, postData: Data?, stubHolder: StubHolderProtocol?) {
        super.init(configuration: configuration, httpMethod: "GET", httpHeaders: httpHeaders, endpoint: endpoint, postData: postData, stubHolder: stubHolder)
    }
    
    open static override func jsonHeaders() -> Dictionary<String, String> {
        var headers = super.jsonHeaders()
        if let apiKey = AuthenticationManager.shared.currentUserKey, let userId = AuthenticationManager.shared.currentUserId {
            headers[AuthenticatedCall.apiKeyHeader] = apiKey
            headers[AuthenticatedCall.apiUserIdHeader] = userId
        }
        return headers
    }

}
