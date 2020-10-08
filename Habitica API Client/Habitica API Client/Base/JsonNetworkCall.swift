//
//  JsonNetworkCall.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import Foundation
import ReactiveSwift
import Prelude

open class JsonNetworkCall: StubbableNetworkCall {
    public lazy var jsonSignal: Signal<Any, Never> = self.dataSignal.skipNil().map {
        return JsonDataHandler.serialize($0)
    }

    public override init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: [String: String]? = nil, endpoint: String, postData: Data?, networkErrorHandler: NetworkErrorHandler? = nil, stubHolder: StubHolderProtocol? = nil, ignoreEtag: Bool = false) {
        super.init(configuration: configuration, httpMethod: httpMethod, httpHeaders: httpHeaders |> JsonNetworkCall.addJsonHeaders, endpoint: endpoint, postData: postData, networkErrorHandler: networkErrorHandler, stubHolder: stubHolder, ignoreEtag: ignoreEtag)
    }

    open class func jsonHeaders() -> [String: String] {
        return ["Content-Type": "application/json", "Accept": "application/json"]
    }

    open class func addJsonHeaders(_ headers: [String: String]?) -> [String: String] {
        if var newHeaders = headers {
            for key in jsonHeaders().keys {
                newHeaders[key] = jsonHeaders()[key]
            }
            return newHeaders
        }
        return jsonHeaders()
    }
}
