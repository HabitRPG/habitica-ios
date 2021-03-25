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
    public let stubHolder: StubHolderProtocol?
    
    public init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: [String: String]?, endpoint: String, postData: Data?, networkErrorHandler: NetworkErrorHandler? = nil, stubHolder: StubHolderProtocol? = nil, ignoreEtag: Bool = false) {
        self.stubHolder = stubHolder
        
        super.init(configuration: configuration, httpMethod: httpMethod, httpHeaders: httpHeaders, endpoint: endpoint, postData: postData, networkErrorHandler: networkErrorHandler, ignoreEtag: ignoreEtag)
    }
    
    open override func fire() {
        if let stubHolder = self.stubHolder, configuration.shouldStub {
            let stubDesc = stub(condition: stubCondition()) { _ in
                if let fileName = stubHolder.stubFileName {
                    if let stubPath = OHPathForFileInBundle(fileName, stubHolder.bundle) {
                        return fixture(filePath: stubPath, status: stubHolder.responseCode, headers: stubHolder.responseHeaders)
                    } else {
                        print("Could not find path for file: \(fileName); is it in the right bundle?")
                    }
                } else if let stubData = stubHolder.stubData {
                    return HTTPStubsResponse(data: stubData, statusCode: stubHolder.responseCode, headers: stubHolder.responseHeaders)
                }
                return HTTPStubsResponse(data: Data(), statusCode: stubHolder.responseCode, headers: stubHolder.responseHeaders)
            }
            self.responseProperty.signal.observeValues({ _ in
                HTTPStubs.removeStub(stubDesc)
            })
        }
        
        super.fire()
    }
    
    open func stubCondition() -> ((URLRequest) -> Bool) {
        return {[weak self] in
            $0.url?.absoluteString == self?.urlString && $0.httpMethod == self?.httpMethod
        }
    }
}
