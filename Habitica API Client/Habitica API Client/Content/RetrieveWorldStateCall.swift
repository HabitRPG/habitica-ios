//
//  RetrieveWorldStateCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveWorldStateCall: ResponseObjectCall<WorldStateProtocol, APIWorldState> {
    public init() {
        super.init(httpMethod: .GET, endpoint: "world-state", needsAuthentication: false)
    }
}
