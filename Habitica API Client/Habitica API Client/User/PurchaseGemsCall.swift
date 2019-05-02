//
//  PurchaseGemsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class PurchaseGemsCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(receipt: [String: Any], recipient: String?, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        var data = ["transaction": receipt]
        if let recipient = recipient {
            data["gift"] = ["uuid": recipient]
        }
        let json = try? JSONSerialization.data(withJSONObject: data, options: [])
        super.init(httpMethod: .POST, endpoint: "iap/ios/verify", postData: json, stubHolder: stubHolder, errorHandler: PrintNetworkErrorHandler())
    }
}
