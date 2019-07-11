//
//  BuyItemCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class BuyObjectCall: ResponseObjectCall<BuyResponseProtocol, APIBuyResponse> {
    public init(key: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/buy/\(key)", postData: nil, stubHolder: stubHolder)
    }
}
