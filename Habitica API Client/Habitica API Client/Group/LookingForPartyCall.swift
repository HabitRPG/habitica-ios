//
//  LookingForPartyCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 14.06.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class LookingForPartyCall: ResponseArrayCall<MemberProtocol, APIMember> {
    public init() {
        super.init(httpMethod: .GET, endpoint: "looking-for-party")
    }
}
