//
//  PurchaseQuestCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class PurchaseQuestCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(key: String) {
        super.init(httpMethod: .POST, endpoint: "user/buy-quest/\(key)", postData: nil)
    }
}
