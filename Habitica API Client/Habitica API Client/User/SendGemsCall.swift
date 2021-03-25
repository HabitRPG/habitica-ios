//
//  SendGemsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 14.05.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SendGemsCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(amount: Int, recipient: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let data: [String: Any] = ["gemAmount": amount,
                    "toUserId": recipient]
        let json = try? JSONSerialization.data(withJSONObject: data, options: [])
        super.init(httpMethod: .POST, endpoint: "members/transfer-gems", postData: json, stubHolder: stubHolder, errorHandler: PrintNetworkErrorHandler())
    }
}
