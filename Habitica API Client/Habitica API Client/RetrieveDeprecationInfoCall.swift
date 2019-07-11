//
//  RetrieveDeprecationInfoCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public class RetrieveDeprecationInfoCall: JsonNetworkCall {
    public init() {
        let configuration = HabiticaServerConfig.aws
        super.init(configuration: configuration, httpMethod: HTTPMethod.GET.rawValue, httpHeaders: nil, endpoint: "deprecation-ios.json", postData: nil, stubHolder: nil)
    }
}
