//
//  SyncUserStatsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 08.01.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SyncUserStatsCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init() {
        super.init(httpMethod: .POST, endpoint: "user/stat-sync")
    }
}
