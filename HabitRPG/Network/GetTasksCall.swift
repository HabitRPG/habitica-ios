//
//  GetTasksCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/18/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift

public class GetTasksCall: ResponseArrayCall<HRPGTask> {
    public init(configuration: ServerConfigurationProtocol = HRPGServerConfig.current, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(configuration: configuration, httpMethod: "GET", endpoint: "tasks/user", postData: nil, stubHolder: stubHolder)
    }
    
    public func fetchTasks() -> SignalProducer<[HRPGTask]?, NSError> {
        return execute()
            .flatMapError { error -> SignalProducer<[HRPGTask]?, NSError> in
                let isHandled = DefaultNetworkErrorHandler.handleError(error: error)
                if !isHandled {
                    
                }
                return SignalProducer(error: error)
        }
    }
}
