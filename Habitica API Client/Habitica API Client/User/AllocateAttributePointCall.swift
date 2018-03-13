//
//  AllocateAttributePointCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class AllocateAttributePointCall: ResponseObjectCall<StatsProtocol, APIStats> {
    public init(attribute: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .POST, endpoint: "user/allocate?stat=\(attribute)", postData: nil, stubHolder: stubHolder)
    }
}
