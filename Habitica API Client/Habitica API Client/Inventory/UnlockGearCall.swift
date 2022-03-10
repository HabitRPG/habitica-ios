//
//  UnlockGearCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 18.01.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UnlockGearCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(gear: [GearProtocol]) {
        let path = gear.map({ (gearItem) -> String in
            return "items.gear.owned.\(gearItem.key ?? "")"
        }).joined(separator: ",")
        super.init(httpMethod: .POST, endpoint: "user/unlock/?path=\(path)", postData: nil)
    }
}
