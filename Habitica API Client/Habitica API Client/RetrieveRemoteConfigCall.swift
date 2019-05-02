//
//  RetrieveRemoteConfigCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public class RetrieveRemoteConfigCall: JsonNetworkCall {
    public init() {
        let configuration = HabiticaServerConfig.aws
        configuration.urlConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        super.init(configuration: configuration, httpMethod: HTTPMethod.GET.rawValue, httpHeaders: nil, endpoint: "config-ios.json", postData: nil, stubHolder: nil)
    }
}
