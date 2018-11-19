//
//  PurchaseGemsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class PurchaseGemsCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(receipt: [String: Any], stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: receipt, options: [])
        super.init(httpMethod: .POST, endpoint: "iap/ios/verify", postData: json, stubHolder: stubHolder, errorHandler: PrintNetworkErrorHandler())
    }
}
