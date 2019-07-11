//
//  SubscribeCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SubscribeCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(sku: String, receipt: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["sku": sku, "receipt": receipt], options: [])
        super.init(httpMethod: .POST, endpoint: "iap/ios/subscribe", postData: json, stubHolder: stubHolder, errorHandler: PrintNetworkErrorHandler())
        needsAuthentication = false
    }
}
