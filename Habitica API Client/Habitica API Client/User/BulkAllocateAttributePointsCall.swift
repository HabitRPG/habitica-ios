//
//  BullkAllocateAttributePoints.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class BulkAllocateAttributePointsCall: ResponseObjectCall<StatsProtocol, APIStats> {
    public init(strength: Int, intelligence: Int, constitution: Int, perception: Int, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let updateDict = ["stats": [
            "str": strength,
            "int": intelligence,
            "con": constitution,
            "per": perception
            ]
        ]
        let json = try? JSONSerialization.data(withJSONObject: updateDict, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/allocate-bulk", postData: json, stubHolder: stubHolder)
    }
}
