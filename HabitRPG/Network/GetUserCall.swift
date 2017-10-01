//
//  GetUserCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift

class GetUserCall: ResponseObjectCall<HRPGUser> {
    public init(configuration: ServerConfigurationProtocol = HRPGServerConfig.current, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(configuration: configuration, httpMethod: "GET", endpoint: "user", postData: nil, stubHolder: stubHolder)
    }
    
    public func fetchUser() -> SignalProducer<HRPGUser?, NSError> {
        return execute()
            .flatMapError { error -> SignalProducer<HRPGUser?, NSError> in
                let isHandled = DefaultNetworkErrorHandler.handleError(error: error)
                if !isHandled {
                    
                }
                return SignalProducer(error: error)
        }
    }
}
