//
//  DebugOutputHandler.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 08.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

class DebugOutputHandler {
    let disposable = ScopedDisposable(CompositeDisposable())
    
    var httpMethod: String = ""
    var url: String = ""
    
    func startNetworkCall() {
        #if DEBUG
            print(Date().debugDescription, "API Client >>>>", httpMethod, url)
        #endif
    }
    
    func observe(call: NetworkCall) {
        #if DEBUG
            disposable.inner.add(Signal<NSError, Never>.merge([call.errorSignal, call.serverErrorSignal]).observeValues({ error in
                print(Date().debugDescription, "ERROR: ", error.localizedDescription)
            }))
            disposable.inner.add(call.httpResponseSignal.observeValues({[weak self] (response) in
                print(Date().debugDescription, "API Client <<<<", self?.httpMethod ?? "", self?.url ?? "", response.statusCode, "\(response.expectedContentLength)bytes")
            }))
        #endif
    }
    
}
