//
//  EquipGearCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class EquipCall: ResponseObjectCall<UserItemsProtocol, APIUserItems> {
    public init(type: String, itemKey: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/equip/\(type)/\(itemKey)", postData: nil, stubHolder: stubHolder)
    }
}
