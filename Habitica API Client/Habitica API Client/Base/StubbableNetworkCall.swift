//
//  StubbableNetworkCall.swift
//  Pods
//
//  Created by Elliot Schrock on 9/15/17.
//
//

import Foundation
import ReactiveSwift
import Habitica_Models

open class StubbableNetworkCall: NetworkCall {

    open var requiresAuthentication: Bool { return false }

    open override func fire() {
        if configuration.shouldStub {
            if let stubData = HabiticaServerConfig.stubs[endpoint] {
                respond(withStub: stubData)
                return
            }
            if requiresAuthentication {
                return
            }
        }
        super.fire()
    }

    private func respond(withStub stubData: CallStub) {
        let data = stubData.takeNextResponse().data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: urlString) ?? URL(fileURLWithPath: "/"),
                                        statusCode: 200, httpVersion: nil, headerFields: nil)
        DispatchQueue.main.async {
            self.responseProperty.value = response
            self.dataProperty.value = data
            self.endCall()
        }
    }

    open func stubCondition() -> ((URLRequest) -> Bool) {
        return {[weak self] in
            $0.url?.absoluteString == self?.urlString && $0.httpMethod == self?.httpMethod
        }
    }
}
