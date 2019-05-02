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
    
    private var httpMethod: HTTPMethod
    private var url: String
    
    init(httpMethod: HTTPMethod, url: String) {
        self.httpMethod = httpMethod
        self.url = url
    }
    
    func startNetworkCall() {
        #if DEBUG
            print(Date().debugDescription, "API Client >>>>", httpMethod.rawValue, url)
        #endif
    }
    
    func observe(call: NetworkCall) {
        #if DEBUG
            disposable.inner.add(Signal<NSError, Never>.merge([call.errorSignal, call.serverErrorSignal]).observeValues({ error in
                print(Date().debugDescription, "ERROR: ", error.localizedDescription)
            }))
            disposable.inner.add(call.httpResponseSignal.observeValues({[weak self] (response) in
                print(Date().debugDescription, "API Client <<<<", self?.httpMethod.rawValue ?? "", self?.url ?? "", response.statusCode, "\(response.expectedContentLength)bytes")
            }))
        #endif
    }
    
}
