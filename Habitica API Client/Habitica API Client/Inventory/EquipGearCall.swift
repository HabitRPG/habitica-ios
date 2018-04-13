//
//  EquipGearCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class EquipGearCall: ResponseObjectCall<UserItemsProtocol, APIUserItems> {
    public init(type: String, gear: GearProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/equip/\(type)/\(gear.key ?? "")", postData: nil, stubHolder: stubHolder)
    }
}
