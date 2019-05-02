//
//  SellItemCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SellItemCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(item: ItemProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/sell/\(item.itemType ?? "")/\(item.key ?? "")", postData: nil, stubHolder: stubHolder)
    }
}
