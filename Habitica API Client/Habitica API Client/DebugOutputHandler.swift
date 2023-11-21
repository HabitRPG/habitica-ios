//
//  DebugOutputHandler.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 08.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models

class DebugOutputHandler {
    let disposable = ScopedDisposable(CompositeDisposable())
    
    var httpMethod: String = ""
    var url: String = ""
    
    func startNetworkCall() {
        #if DEBUG
        logger.log("\(httpMethod) \(url)")
        #endif
    }
    
    func observe(call: NetworkCall) {
        #if DEBUG
            disposable.inner.add(Signal.merge([call.errorSignal, call.serverErrorSignal]).observeValues({ error in
                logger.log(error)
            }))
            disposable.inner.add(call.httpResponseSignal.observeValues({[weak self] (response) in
                logger.log("<<< \(self?.httpMethod ?? "") \(self?.url ?? "") \(response.statusCode) \(response.expectedContentLength)bytes")
            }))
        #endif
    }
    
}
