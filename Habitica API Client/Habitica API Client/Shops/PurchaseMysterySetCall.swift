//
//  PurchaseMysterySetCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class PurchaseMysterySetCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(identifier: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/buy-mystery-set/\(identifier)", postData: nil, stubHolder: stubHolder)
    }
}
