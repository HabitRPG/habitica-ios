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

public class AuthenticatedCall: JsonNetworkCall {
    let disposable = ScopedDisposable(CompositeDisposable())
    fileprivate static let apiKeyHeader = "x-api-key"
    fileprivate static let apiUserIdHeader = "x-api-user"
    
    public override init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: Dictionary<String, String>? = AuthenticatedCall.jsonHeaders(), endpoint: String, postData: Data?, stubHolder: StubHolderProtocol?) {
        super.init(configuration: configuration, httpMethod: httpMethod, httpHeaders: httpHeaders, endpoint: endpoint, postData: postData, stubHolder: stubHolder)
        
        #if DEBUG
            disposable.inner.add(serverErrorSignal.observeValues( { error in
                print(error.localizedDescription)
            }))
            disposable.inner.add(httpResponseSignal.observeValues({[weak self] (response) in
                print("Response:", httpMethod, self?.urlString(endpoint) ?? "", response.statusCode)
            }))
        #endif
    }
    
    open static override func jsonHeaders() -> Dictionary<String, String> {
        var headers = super.jsonHeaders()
        if let apiKey = NetworkAuthenticationManager.shared.currentUserKey, let userId = NetworkAuthenticationManager.shared.currentUserId {
            headers[AuthenticatedCall.apiKeyHeader] = apiKey
            headers[AuthenticatedCall.apiUserIdHeader] = userId
        }
        return headers
    }
    
    public override func fire() {
        #if DEBUG
            print("Network Call:", httpMethod, urlString(endpoint))
        #endif
        super.fire()
    }
    
}
