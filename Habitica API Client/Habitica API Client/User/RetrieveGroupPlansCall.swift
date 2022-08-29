//
//  RetrieveGroupPlansCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveGroupPlansCall: ResponseArrayCall<GroupPlanProtocol, APIGroupPlan> {
    public init() {
        super.init(httpMethod: .GET, endpoint: "group-plans")
    }
}
