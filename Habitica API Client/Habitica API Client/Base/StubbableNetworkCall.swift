//
//  StubbableNetworkCall.swift
//  Pods
//
//  Created by Elliot Schrock on 9/15/17.
//
//

import Foundation
import OHHTTPStubs
import ReactiveSwift

open class StubbableNetworkCall: NetworkCall {
    
    open override func fire() {
        if configuration.shouldStub {
            if let stubData = HabiticaServerConfig.stubs[endpoint] {
                let stubDesc = stub(condition: stubCondition()) { _ in
                    // swiftlint:disable:next force_unwrapping
                    return HTTPStubsResponse(data: stubData.data(using: .utf8)!, statusCode: 200, headers: nil)
                }
                self.responseProperty.signal.observeValues({ _ in
                    HTTPStubs.removeStub(stubDesc)
                })
            }
        }
        
        super.fire()
    }
    
    open func stubCondition() -> ((URLRequest) -> Bool) {
        return {[weak self] in
            $0.url?.absoluteString == self?.urlString && $0.httpMethod == self?.httpMethod
        }
    }
}
